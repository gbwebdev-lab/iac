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

# The main fabric is created during MAAS installation, and we have nothing to change with it so we simply use a data source
data "maas_fabric" "lab" {
  name = "lab"
}

# Created during MAAS installation, so must be imported during TF setup (check README.md)
resource "maas_vlan" "lab_infra_mgt" {
  fabric =  data.maas_fabric.lab.id
  vid    = 0
  name   = "untagged"
  dhcp_on = false
  mtu = 1500
}

# Created during MAAS installation, so must be imported during TF setup (check README.md)
resource "maas_subnet" "lab_infra_mgt" {
  cidr       = "10.0.22.0/24"
  fabric     = data.maas_fabric.lab.id
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

module "machines" {
  for_each = var.machines
  source   = "./modules/baremetal"

  depends_on = [ maas_dns_domain.lab ]

  hostname                            = each.value.hostname
  architecture                        = each.value.architecture
  domain                              = each.value.domain
  distro_series                       = each.value.distro_series
  pxe_mac_address                     = each.value.pxe_mac_address
  main_nic_name                       = each.value.main_nic_name
  main_nic_vlan_id                    = maas_vlan.lab_infra_mgt.id
  main_nic_subnet_id                  = maas_subnet.lab_infra_mgt.id  

  main_nvme_disk_model                = each.value.main_nvme_disk_model
  main_nvme_disk_serial               = each.value.main_nvme_disk_serial
  main_nvme_disk_device_name          = each.value.main_nvme_disk_device_name
  main_nvme_disk_size                 = each.value.main_nvme_disk_size
  main_nvme_disk_efi_partition_size   = each.value.main_nvme_disk_efi_partition_size
  main_nvme_disk_root_partition_size  = each.value.main_nvme_disk_root_partition_size
  main_nvme_disk_log_partition_size   = each.value.main_nvme_disk_log_partition_size
  main_nvme_disk_lvm_partition_size   = each.value.main_nvme_disk_lvm_partition_size
  main_nvme_disk_lvm_partition_detail = each.value.main_nvme_disk_lvm_partition_detail

  extra_disks                = each.value.extra_disks
}