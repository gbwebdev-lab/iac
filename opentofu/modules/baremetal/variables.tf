variable "hostname" {
  description = "Hostname of the machine"
  type        = string
}

variable "architecture" {
  description = "Architecture of the machine"
  type        = string
  default     = "amd64/generic"
}

variable "domain" {
  description = "Domain of the machine"
  type        = string
  default     = "lab"
}

variable "distro_series" {
  description = "Distro series of the machine"
  type        = string
  default     = "noble"
}

variable "pxe_mac_address" {
  description = "MAC address of the machine"
  type        = string
}

variable "main_nic_name" {
  description = "Name of the main NIC"
  type        = string
  default     = "enp2s0f0"
}

variable "main_nic_vlan_id" {
  description = "ID of the maas_vlan for main NIC"
  type        = number
  default     = 0
}

variable "main_nic_subnet_id" {
  description = "ID of the maas_subnet for main NIC"
  type        = number
  default     = 0
}

variable "main_nvme_disk_model" {
  description = "Model of the NVMe disk"
  type        = string
  default     = "WD PC SN740 SDDQNQD-256G-1001"
}

variable "main_nvme_disk_serial" {
  description = "Serial number of the NVMe disk"
  type        = string
}

variable "main_nvme_disk_device_name" {
  description = "System name of the NVMe disk device"
  type        = string
  default     = "nvme0n1"
}

variable "main_nvme_disk_size" {
  description = "Size of the NVMe disk in GB"
  type        = number
  default     = 238
}

variable "main_nvme_disk_efi_partition_size" {
  description = "Size of the EFI partition in GB"
  type        = number
  default     = 1
}

variable "main_nvme_disk_root_partition_size" {
  description = "Size of the root (/) partition in GB"
  type        = number
  default     = 34
}

variable "main_nvme_disk_log_partition_size" {
  description = "Size of the /var/log partition in GB"
  type        = number
  default     = 8
}

variable "main_nvme_disk_lvm_partition_size" {
  description = "Size of the LVM partition in GB"
  type        = number
  default     = 194
}

variable "main_nvme_disk_lvm_partition_detail" {
  description = "List of logical volumes to create on main nvme"
  type = list(object({
    name       = string
    size       = number  # in GB
    mount_path = string
    filesystem = string  # e.g. ext4, xfs, etc.
  }))
  default = [
    {
      name = "var_kubelet"
      size = 55
      mount_path = "/var/lib/kubelet"
      filesystem = "ext4"
    },
    {
      name = "var_containerd"
      size = 137
      mount_path = "/var/lib/containerd"
      filesystem = "ext4"
    },
  ]
}

variable "extra_disks" {
  description = "List of extra disks"
  type = list(object({
    model = string
    serial = string
    device_name = string
    size = number
    tags = list(string)
    lvm_partition_detail = list(object({
      name       = string
      size       = number  # in GB
      mount_path = string
      filesystem = string  # e.g. ext4, xfs, etc.
    }))
  }))
  default = [ ]
}
