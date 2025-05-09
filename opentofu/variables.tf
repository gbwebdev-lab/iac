# MAAS provider
variable "maas_api_url" {
  description = "MAAS API URL"
  type        = string
}

variable "maas_api_key" {
  description = "MAAS API key"
  type        = string
  sensitive   = true
}

variable "machines" {
  description = "Map of all bare metal nodes to provision"
  type = map(object({
    hostname                            = string
    architecture                        = string
    domain                              = string
    distro_series                       = string
    pxe_mac_address                     = string
    main_nic_name                       = string
    main_nvme_disk_model                = string
    main_nvme_disk_serial               = string
    main_nvme_disk_device_name          = string
    main_nvme_disk_size                 = number
    main_nvme_disk_efi_partition_size   = number
    main_nvme_disk_root_partition_size  = number
    main_nvme_disk_log_partition_size   = number
    main_nvme_disk_lvm_partition_size   = number
    main_nvme_disk_lvm_partition_detail = list(object({
        name       = string
        size       = number  # in GB
        mount_path = string
        filesystem = string  # e.g. ext4, xfs, etc.
      }))
    extra_disks = list(object({
      model        = string
      serial       = string
      device_name  = string
      size         = number
      tags         = list(string)
      lvm_partition_detail = list(object({
        name       = string
        size       = number  # in GB
        mount_path = string
        filesystem = string  # e.g. ext4, xfs, etc.
      }))
    }))
  }))
}
