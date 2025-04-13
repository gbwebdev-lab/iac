#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

# Add your SSH public key
ssh_authorized_keys:
  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXZ9OLEwcxzuMPXYJyhNBDnawJvXCwQZLm28kZ0flxJ guillaume@LP-Guillaume
  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILO9kGZmoqzzsSi/l2rbS8uGtPEFD3P5xd5TVi5ejtnj guillaume@PC-Guillaume

# Upgrade all packages on first boot
package_update: true
package_upgrade: true

# (Optional) Install extra packages
packages:
  - lvm2
  - curl
  - htop
  - vim
  - nano
  - git
  - wget
  - net-tools
  - iputils-ping
  - ca-certificates
  - apt-transport-https

runcmd:
  - |
    MAIN_PV_DEVICE=/dev/${nvme_disk_device_name}p${main_nvme_disk_lvm_partition_index}

    if [ -e "$MAIN_PV_DEVICE" ]; then
      if [ "${main_nvme_disk_lvm_partition_size}" -gt "0" ]; then
        # Create Physical Volume
        echo "Creating PV on $MAIN_PV_DEVICE"
        pvcreate "$MAIN_PV_DEVICE"

        MAIN_VG_NAME=vg_main

        # Create Volume Group
        echo "Creating VG on $MAIN_PV_DEVICE"
        vgcreate "$MAIN_VG_NAME" "$MAIN_PV_DEVICE"
      fi
      # Create & format main LVs
      ${indent(6, main_lvs_script)}
    fi

    # Extra disks (if any)
    ${indent(4, extra_disks_script)}

    # Mount immediately
    mount -a