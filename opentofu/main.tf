terraform {
  backend "s3" {
    # The following will be overridden by a ".backend.config" file (check README.md)
    bucket = ""
    key    = ""
    region = "us-east-1"
    endpoint = ""
    skip_credentials_validation = false
    skip_metadata_api_check     = false
  }
  required_providers {
    maas = {
      source = "canonical/maas"
      version = ">= 0.9.0"
    }
  }
}

provider "maas" {
  api_url = var.maas_api_url
  api_key = var.maas_api_key
}

# Created during MAAS installation, so must be imported during TF setup (check README.md)
resource "maas_fabric" "lab" {
  name = "lab"
}

# Created during MAAS installation, so must be imported during TF setup (check README.md)
resource "maas_vlan" "lab_infra_mgt" {
  fabric =  maas_fabric.lab.id
  vid    = 0
  name   = "untagged"
  dhcp_on = false
  mtu = 1500
}

# Created during MAAS installation, so must be imported during TF setup (check README.md)
resource "maas_subnet" "lab_infra_mgt" {
  cidr       = "10.0.22.0/24"
  fabric     = maas_fabric.lab.id
  vlan       = maas_vlan.lab_infra_mgt.vid
  name       = "lab_infra_mgt"
  allow_dns  = false
  rdns_mode  = 0
  gateway_ip = "10.0.22.253"
  dns_servers = [
    "10.0.22.253",
  ]
  # ip_ranges {
  # }
}

resource "maas_dns_domain" "lab" {
  name          = "lab"
  ttl           = 3600
  authoritative = false
  is_default    = true
}

# Declaring a "maas_machine" ressource is equivalent to adding a machine in MAAS and provisionning it.
resource "maas_machine" "k8s-m01" {
  depends_on = [ maas_dns_domain.lab ]
  hostname      = "k8s-m01"
  architecture  = "amd64/generic"
  domain        = "lab"
  zone          = "default"

  power_type = "webhook"
  power_parameters = jsonencode({
    power_on_uri    = "http://10.0.22.1:5000/nodes/k8s-m01/power-on"
    power_off_uri   = "http://10.0.22.1:5000/nodes/k8s-m01/power-off"
    power_query_uri = "http://10.0.22.1:5000/nodes/k8s-m01/state"
    power_on_regex  = ".*ON.*"
    power_off_regex = ".*OFF.*"
    # TODO : set a token for the webhook and use power_token
  })
  pxe_mac_address = "6c:4b:90:b8:f2:fe"
}


# MAAS does not support LVM (at least using TF) so we will stick to "flat" layout for system and leave a big chunk of space for LVM that will later be setup with Ansible.
resource "maas_block_device" "k8s-m01-nvme0n1"{
  machine        = maas_machine.k8s-m01.id
  model          = "WD PC SN740 SDDQNQD-256G-1001"
  serial         = "22382D803032"
  name           = "nvme0n1"
  size_gigabytes = 238
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
        size_gigabytes = 1
        tags           = []
    }
    partitions {
        bootable       = false
        fs_type        = "ext4"
        label          = "root"
        mount_point    = "/"
        size_gigabytes = 34
        tags           = []
    }
    partitions {
        bootable       = false
        fs_type        = "ext4"
        label          = "logs"
        mount_point    = "/var/log"
        size_gigabytes = 8
        tags           = []
    }
    partitions {
        bootable       = false
        fs_type        = ""
        label          = "cont"
        mount_point    = ""
        size_gigabytes = 194
        tags           = []
    }
}

resource "maas_network_interface_physical" "k8s-m01-enp2s0f0" {
  mac_address = maas_machine.k8s-m01.pxe_mac_address
  machine     = maas_machine.k8s-m01.id
  mtu         = 1500
  tags        = []
  vlan        = maas_vlan.lab_infra_mgt.id
}

resource "maas_network_interface_link" "k8s-m01-enp2s0f0" {
  machine           = maas_machine.k8s-m01.id
  network_interface = maas_network_interface_physical.k8s-m01-enp2s0f0.id
  subnet            = maas_subnet.lab_infra_mgt.id
  mode              = "DHCP"  # The IP address will be assigned by the router's DHCP server
}

# Declaring a "maas_instance" ressource is equivalent to deploying a machine in MAAS (after provisionning).
resource "maas_instance" "k8s-m01" {
  depends_on = [ maas_block_device.k8s-m01-nvme0n1, maas_network_interface_link.k8s-m01-enp2s0f0 ]
  count = 1
  allocate_params {
    hostname      = maas_machine.k8s-m01.hostname
  }
  deploy_params {
    distro_series = "noble"
    user_data = file("cloud-init/k8s-m01.yaml")
  }
}