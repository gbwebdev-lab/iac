machines = {
  nuc = {
    hostname                            = "nuc"
    architecture                        = "amd64/generic"
    domain                              = "lab"
    distro_series                       = "noble"
    main_nic_name                       = "eno1"
    pxe_mac_address                     = "B8:AE:ED:7E:77:54"

    # Main NVMe disk (for system + empty LVM)
    main_nvme_disk_model                = "Samsung SSD 980 250GB"
    main_nvme_disk_serial               = "S64BNF0T310539F"
    main_nvme_disk_device_name          = "nvme0n1"
    main_nvme_disk_size                 = 232
    main_nvme_disk_efi_partition_size   = 1
    main_nvme_disk_root_partition_size  = 40
    main_nvme_disk_log_partition_size   = 8
    main_nvme_disk_lvm_partition_size   = 182

    main_nvme_disk_lvm_partition_detail = [
    ]

    extra_disks = [
    ]

  },
  k8s-m01 = {
    hostname                            = "k8s-m01"
    architecture                        = "amd64/generic"
    domain                              = "lab"
    distro_series                       = "noble"
    main_nic_name                       = "enp2s0f0"
    pxe_mac_address                     = "6C:4B:90:B8:F2:FE"

    # Main NVMe disk (for system + empty LVM)
    main_nvme_disk_model                = "WD PC SN740 SDDQNQD-256G-1001"
    main_nvme_disk_serial               = "22382D803032"
    main_nvme_disk_device_name          = "nvme0n1"
    main_nvme_disk_size                 = 238
    main_nvme_disk_efi_partition_size   = 1
    main_nvme_disk_root_partition_size  = 34
    main_nvme_disk_log_partition_size   = 8
    main_nvme_disk_lvm_partition_size   = 194

    main_nvme_disk_lvm_partition_detail = [
      {
        name       = "var_kubelet"
        size       = 50
        mount_path = "/var/lib/kubelet"
        filesystem = "ext4"
      },
      {
        name       = "var_containerd"
        size       = 60
        mount_path = "/var/lib/containerd"
        filesystem = "ext4"
      }
    ]

    extra_disks = [
    ]

  },
  k8s-m02 = {
    hostname                            = "k8s-m02"
    architecture                        = "amd64/generic"
    domain                              = "lab"
    distro_series                       = "noble"
    main_nic_name                       = "enp2s0f0"
    pxe_mac_address                     = "6C:4B:90:B8:21:B8"

    # Main NVMe disk (for system + empty LVM)
    main_nvme_disk_model                = "WD PC SN740 SDDQNQD-256G-1001"
    main_nvme_disk_serial               = "22382D810787"
    main_nvme_disk_device_name          = "nvme0n1"
    main_nvme_disk_size                 = 238
    main_nvme_disk_efi_partition_size   = 1
    main_nvme_disk_root_partition_size  = 34
    main_nvme_disk_log_partition_size   = 8
    main_nvme_disk_lvm_partition_size   = 194

    main_nvme_disk_lvm_partition_detail = [
      {
        name       = "var_kubelet"
        size       = 50
        mount_path = "/var/lib/kubelet"
        filesystem = "ext4"
      },
      {
        name       = "var_containerd"
        size       = 60
        mount_path = "/var/lib/containerd"
        filesystem = "ext4"
      }
    ]

    extra_disks = [
    ]

  },
  k8s-m03 = {
    hostname                            = "k8s-m03"
    architecture                        = "amd64/generic"
    domain                              = "lab"
    distro_series                       = "noble"
    main_nic_name                       = "enp0s31f6"
    pxe_mac_address                     = "6C:4B:90:14:FE:95"

    # Main NVMe disk (for system + empty LVM)
    main_nvme_disk_model                = "WD PC SN740 SDDQNQD-256G-1001"
    main_nvme_disk_serial               = "223205803764"
    main_nvme_disk_device_name          = "nvme0n1"
    main_nvme_disk_size                 = 238
    main_nvme_disk_efi_partition_size   = 1
    main_nvme_disk_root_partition_size  = 34
    main_nvme_disk_log_partition_size   = 8
    main_nvme_disk_lvm_partition_size   = 194

    main_nvme_disk_lvm_partition_detail = [
      {
        name       = "var_kubelet"
        size       = 50
        mount_path = "/var/lib/kubelet"
        filesystem = "ext4"
      },
      {
        name       = "var_containerd"
        size       = 60
        mount_path = "/var/lib/containerd"
        filesystem = "ext4"
      }
    ]

    extra_disks = [
    ]

  },
  k8s-w01 = {
    hostname                            = "k8s-w01"
    architecture                        = "amd64/generic"
    domain                              = "lab"
    distro_series                       = "noble"
    main_nic_name                       = "enp2s0f0"
    pxe_mac_address                     = "6C:4B:90:B8:21:9C"

    # Main NVMe disk (for system + empty LVM)
    main_nvme_disk_model                = "SAMSUNG MZVL4256HBJD-00BL7"
    main_nvme_disk_serial               = "S67WNF1W858774"
    main_nvme_disk_device_name          = "nvme0n1"
    main_nvme_disk_size                 = 238
    main_nvme_disk_efi_partition_size   = 1
    main_nvme_disk_root_partition_size  = 34
    main_nvme_disk_log_partition_size   = 8
    main_nvme_disk_lvm_partition_size   = 194

    main_nvme_disk_lvm_partition_detail = [
      {
        name       = "var_kubelet"
        size       = 50
        mount_path = "/var/lib/kubelet"
        filesystem = "ext4"
      },
      {
        name       = "var_containerd"
        size       = 60
        mount_path = "/var/lib/containerd"
        filesystem = "ext4"
      }
    ]

    extra_disks = [
      {
        model       = "SanDisk SD8SB8U-"
        serial      = "181440801111"
        device_name = "sda"
        size        = 119
        tags        = ["ssd", "data"]
        lvm_partition_detail = [
          {
            name       = "ceph"
            size       = 60
            mount_path = ""
            filesystem = ""
          }
        ]
      }
    ]

  },
  k8s-w02 = {
    hostname                            = "k8s-w02"
    architecture                        = "amd64/generic"
    domain                              = "lab"
    distro_series                       = "noble"
    main_nic_name                       = "enp2s0f0"
    pxe_mac_address                     = "6C:4B:90:B8:F2:B7"

    # Main NVMe disk (for system + empty LVM)
    main_nvme_disk_model                = "WD PC SN740 SDDQNQD-256G-1001"
    main_nvme_disk_serial               = "22382D811157"
    main_nvme_disk_device_name          = "nvme0n1"
    main_nvme_disk_size                 = 238
    main_nvme_disk_efi_partition_size   = 1
    main_nvme_disk_root_partition_size  = 34
    main_nvme_disk_log_partition_size   = 8
    main_nvme_disk_lvm_partition_size   = 194

    main_nvme_disk_lvm_partition_detail = [
      {
        name       = "var_kubelet"
        size       = 50
        mount_path = "/var/lib/kubelet"
        filesystem = "ext4"
      },
      {
        name       = "var_containerd"
        size       = 60
        mount_path = "/var/lib/containerd"
        filesystem = "ext4"
      }
    ]

    extra_disks = [
      {
        model       = "SanDisk SD8SB8U-"
        serial      = "181440801166"
        device_name = "sda"
        size        = 119
        tags        = ["ssd", "data"]
        lvm_partition_detail = [
          {
            name       = "ceph"
            size       = 60
            mount_path = ""
            filesystem = ""
          }
        ]
      }
    ]

  },
  k8s-w03 = {
    hostname                            = "k8s-w03"
    architecture                        = "amd64/generic"
    domain                              = "lab"
    distro_series                       = "noble"
    main_nic_name                       = "enp2s0f0"
    pxe_mac_address                     = "6C:4B:90:B6:47:00"

    # Main NVMe disk (for system + empty LVM)
    main_nvme_disk_model                = "WD PC SN740 SDDQNQD-256G-1001"
    main_nvme_disk_serial               = "22382D803009"
    main_nvme_disk_device_name          = "nvme0n1"
    main_nvme_disk_size                 = 238
    main_nvme_disk_efi_partition_size   = 1
    main_nvme_disk_root_partition_size  = 34
    main_nvme_disk_log_partition_size   = 8
    main_nvme_disk_lvm_partition_size   = 194

    main_nvme_disk_lvm_partition_detail = [
      {
        name       = "var_kubelet"
        size       = 50
        mount_path = "/var/lib/kubelet"
        filesystem = "ext4"
      },
      {
        name       = "var_containerd"
        size       = 60
        mount_path = "/var/lib/containerd"
        filesystem = "ext4"
      }
    ]

    extra_disks = [
      {
        model       = "SanDisk SD8SB8U-"
        serial      = "181440801392"
        device_name = "sda"
        size        = 119
        tags        = ["ssd", "data"]
        lvm_partition_detail = [
          {
            name       = "ceph"
            size       = 60
            mount_path = ""
            filesystem = ""
          }
        ]
      }
    ]

  },
}