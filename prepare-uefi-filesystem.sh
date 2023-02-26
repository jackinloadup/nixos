#!/bin/sh

set -eux

INSTALL_DRIVE_NAME="/dev/$1"
INSTALL_DRIVE_PASSWORD="$2"

# The size of the boot partition.
BOOT_SIZE=1024MiB

# Partition using gpt as required by UEFI.
sudo -i parted $INSTALL_DRIVE_NAME -- mklabel gpt
# Boot partition
sudo -i parted $INSTALL_DRIVE_NAME -- mkpart ESP fat32 1MiB $BOOT_SIZE
# Primary partition
sudo -i parted $INSTALL_DRIVE_NAME -- mkpart primary btrfs $BOOT_SIZE 100%
# Enable the boot partition.
sudo -i parted $INSTALL_DRIVE_NAME -- set 1 boot on

# Generate keys for single password unlock
#sudo -i dd if=/dev/urandom of=/keyfile0.bin bs=1024 count=4

# Setup encryption on the primary partition.
sudo sh -c "echo $INSTALL_DRIVE_PASSWORD | cryptsetup luksFormat --cipher aes-xts-plain64 --key-size 256 /dev/disk/by-partlabel/primary"
# Add a second key used by initramfs to decrypt partition without second password entry
#sudo sh -c "echo $INSTALL_DRIVE_PASSWORD | cryptsetup luksAddKey /dev/disk/by-partlabel/primary /keyfile0.bin"
# Mount a decrypted version of the encrypted primary partition.
#sudo sh -c "echo $INSTALL_DRIVE_PASSWORD | cryptsetup luksOpen --key-file /keyfile0.bin /dev/disk/by-partlabel/primary os-decrypted"
sudo sh -c "echo $INSTALL_DRIVE_PASSWORD | cryptsetup luksOpen /dev/disk/by-partlabel/primary os-decrypted-script"

# Format the boot partition.
#sudo -i mkfs.fat -F 32 -n efi /dev/disk/by-partlabel/ESP
sudo -i mkfs.fat -F 32 -n efi ${INSTALL_DRIVE_NAME}p1
# Format the decrypted version of the primary partition.
#sudo -i mkfs.ext4 -L nixos /dev/mapper/os-decrypted
sudo -i mkfs.btrfs -L nixos /dev/mapper/os-decrypted-script

# With LVM
#sudo -i pvcreate /dev/mapper/os-decrypted
#sudo -i vgcreate os-volume-group /dev/mapper/os-decrypted
#sudo -i lvcreate --size 2G --name swap os-volume-group
#sudo -i lvcreate --extents '100%FREE' --name root  os-volume-group
#sudo -i mkswap --label swap /dev/os-volume-group/swap
#sudo -i mkfs.ext4 -L nixos /dev/os-volume-group/root

# Wait for disk labels to be ready.
sleep 4

# Mount the primary
sudo -i mount -o noatime /dev/mapper/os-decrypted-script /mnt

# create btrfs subvols
sudo -i btrfs subvolume create /mnt/nix
sudo -i btrfs subvolume create /mnt/etc
sudo -i btrfs subvolume create /mnt/log
sudo -i btrfs subvolume create /mnt/root
sudo -i btrfs subvolume create /mnt/home
sudo -i btrfs subvolume create /mnt/persist
sudo -i umount /mnt

# Start tmpfs root
sudo -i mount -t tmpfs -o mode=755 none /mnt
sudo -i mkdir -p /mnt/{boot,nix,etc,var/log,root,home,persist}

# mount boot
#sudo -i mkdir -p /mnt/boot
sudo -i mount -o noatime ${INSTALL_DRIVE_NAME}p1 /mnt/boot

# mount persistant storage
sudo -i mount -o subvol=nix,compress-force=zstd,noatime     /dev/mapper/os-decrypted-script /mnt/nix
sudo -i mount -o subvol=etc,compress-force=zstd,noatime     /dev/mapper/os-decrypted-script /mnt/etc
sudo -i mount -o subvol=log,compress-force=zstd,noatime     /dev/mapper/os-decrypted-script /mnt/var/log
sudo -i mount -o subvol=root,compress-force=zstd,noatime    /dev/mapper/os-decrypted-script /mnt/root
sudo -i mount -o subvol=persist,compress-force=zstd,noatime /dev/mapper/os-decrypted-script /mnt/persist
sudo -i mount -o subvol=home,compress-force=zstd            /dev/mapper/os-decrypted-script /mnt/home

# Prepare a directory to place dotfiles.
#sudo -i mkdir -p /mnt/etc/dotfiles/nixos
#sudo -i chown -R nixos /mnt/etc/dotfiles/nixos

# Prepare the directory to place the nix configuration.
sudo -i mkdir -p /mnt/etc/nixos
#sudo -i chown -R nixos /mnt/etc/nixos

# Copy the keys
#sudo -i mkdir -p /mnt/etc/secrets/initrd/
#sudo -i cp /keyfile0.bin /mnt/etc/secrets/initrd
#sudo -i chmod 000 /mnt/etc/secrets/initrd/keyfile*.bin
