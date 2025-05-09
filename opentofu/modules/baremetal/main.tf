terraform {
  required_providers {
    maas = {
      source = "canonical/maas"
      version = ">= 0.9.0"
    }
  }
}

# Declaring a "maas_machine" ressource is equivalent to adding a machine in MAAS and provisionning it.
resource "maas_machine" "this" {
  hostname      = var.hostname
  architecture  = var.architecture
  domain        = var.domain
  zone          = "default"

  power_type = "webhook"
  power_parameters = jsonencode({
    power_on_uri    = "http://10.0.22.1:5000/nodes/${var.hostname}/power-on"
    power_off_uri   = "http://10.0.22.1:5000/nodes/${var.hostname}/power-off"
    power_query_uri = "http://10.0.22.1:5000/nodes/${var.hostname}/state"
    power_on_regex  = ".*ON.*"
    power_off_regex = ".*OFF.*"
    # TODO : set a token for the webhook and use power_token
  })
  pxe_mac_address = var.pxe_mac_address
}


# MAAS does not support LVM (at least using TF) so we will stick to "flat" layout for system and leave a big chunk of space for LVM that will later be setup with Ansible.
resource "maas_block_device" "main_nvme"{
  machine        = maas_machine.this.id
  model          = var.main_nvme_disk_model
  serial         = var.main_nvme_disk_serial
  name           = var.main_nvme_disk_device_name
  size_gigabytes = var.main_nvme_disk_size
  block_size     = 512
  is_boot_device = true
  tags = [
      "ssd",
      "system"
    ]
    partitions {
        bootable       = true
        fs_type        = "fat32"
        label          = "efi"
        mount_point    = "/boot/efi"
        size_gigabytes = var.main_nvme_disk_efi_partition_size
        tags           = []
    }
    partitions {
        bootable       = false
        fs_type        = "ext4"
        label          = "root"
        mount_point    = "/"
        size_gigabytes = var.main_nvme_disk_root_partition_size
        tags           = []
    }
    partitions {
        bootable       = false
        fs_type        = "ext4"
        label          = "logs"
        mount_point    = "/var/log"
        size_gigabytes = var.main_nvme_disk_log_partition_size
        tags           = []
    }
    partitions {
        bootable       = false
        fs_type        = ""
#        label          = "cont"    # Label not taken into account by MAAS on raw partition : try to recreate every time
        mount_point    = ""
        size_gigabytes = var.main_nvme_disk_lvm_partition_size
        tags           = []
    }
}

# MAAS does not support LVM (at least using TF) so we will stick to "flat" layout for system and leave a big chunk of space for LVM that will later be setup with Ansible.
resource "maas_block_device" "extra_disks"{
  for_each       = { for d in var.extra_disks : d.device_name => d }
  machine        = maas_machine.this.id
  model          = each.value.model
  serial         = each.value.serial
  name           = each.value.device_name
  size_gigabytes = each.value.size
  block_size     = 512
  is_boot_device = false
  tags = each.value.tags
  partitions {
      bootable       = false
      fs_type        = ""
      #label          = "lvm-${each.value.device_name}"  # Label not taken into account by MAAS on raw partition : try to recreate every time
      mount_point    = ""
      size_gigabytes = each.value.size - 1
      tags           = []
  }
}

# A dummy resource to enforce depencies on extra disks
resource "terraform_data" "wait_for_extra_disks" {
  triggers_replace = {
    disks_ids = join(",", [for _, disk in maas_block_device.extra_disks : disk.id])
  }
}

# resource "maas_network_interface_physical" "main_nic" {
#   name        = var.main_nic_name
#   mac_address = var.pxe_mac_address
#   machine     = maas_machine.this.id  
#   mtu         = 1500
#   tags        = []
#   vlan        = var.main_nic_vlan_id
# }

data "maas_network_interface_physical" "main_nic" {
  name        = var.main_nic_name 
  machine     = maas_machine.this.id  
}

resource "maas_network_interface_link" "main_nic" {
  machine           = maas_machine.this.id
  network_interface = data.maas_network_interface_physical.main_nic.id
  subnet            = var.main_nic_subnet_id # maas_subnet.lab_infra_mgt.id
  mode              = "DHCP"  # The IP address will be assigned by the router's DHCP server
}


locals {
  main_lvs_script = join("\n", [
    for lv in var.main_nvme_disk_lvm_partition_detail : <<-EOL
      echo "Creating LV ${lv.name}"
      lvcreate -n ${lv.name} -L ${lv.size}G "$MAIN_VG_NAME"
      mkfs.${lv.filesystem} "/dev/$MAIN_VG_NAME/${lv.name}"

      echo "Creating mount point ${lv.mount_path}"
      mkdir -p ${lv.mount_path}

      echo "Adding ${lv.mount_path} to /etc/fstab"
      echo "/dev/$MAIN_VG_NAME/${lv.name} ${lv.mount_path} ${lv.filesystem} defaults 0 2" >> /etc/fstab
    EOL
  ])
}


locals {
  extra_disks_script = join("\n\n", [
    for disk in var.extra_disks : <<-EOD
      # Create PV for ${disk.device_name}
      PV_DEVICE=/dev/${disk.device_name}1
      echo "Creating PV on $PV_DEVICE"
      pvcreate "$PV_DEVICE"

      # Create VG
      VG_NAME="vg_${disk.device_name}"
      echo "Creating VG $VG_NAME"
      vgcreate "$VG_NAME" "$PV_DEVICE"

      # Create each LV for this disk
      ${join("\n", [
        for lv in disk.lvm_partition_detail : <<-EOF
          echo "Creating LV ${lv.name} in $VG_NAME"
          lvcreate -n ${lv.name} -L ${lv.size}G $VG_NAME
          if [ ! -z "${lv.filesystem}" ]; then
            mkfs.${lv.filesystem} /dev/$VG_NAME/${lv.name}
          fi

          if [ ! -z "${lv.mount_path}" ]; then
            echo "Mounting ${lv.mount_path}"
            mkdir -p ${lv.mount_path}
            echo "/dev/$VG_NAME/${lv.name} ${lv.mount_path} ${lv.filesystem} defaults 0 2" >> /etc/fstab
          fi

        EOF
      ])}
    EOD
  ])
}


# Declaring a "maas_instance" ressource is equivalent to deploying a machine in MAAS (after provisionning).
resource "maas_instance" "this" {
  depends_on = [ maas_block_device.main_nvme, maas_network_interface_link.main_nic, terraform_data.wait_for_extra_disks ]
  count = 1
  allocate_params {
    hostname      = maas_machine.this.hostname
  }
  deploy_params {
    distro_series = var.distro_series
    user_data = templatefile("${path.module}/cloud-init/user_data.tpl", {
      hostname                            = var.hostname
      nvme_disk_device_name               = var.main_nvme_disk_device_name
      main_nvme_disk_lvm_partition_index  = 4
      main_nvme_disk_lvm_partition_size   = var.main_nvme_disk_lvm_partition_size
      main_lvs_script                     = local.main_lvs_script
      extra_disks_script                  = local.extra_disks_script
    })
  }
}
