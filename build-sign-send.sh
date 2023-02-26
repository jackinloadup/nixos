#!/usr/bin/env bash
#
# Build
# Sign
# Send
#
### This script is intended to be used from a nix "build host" which would have
### the built derivation. The original goal was to be able to rapidly test
### changes to the install process.
###
### Expected use
###  - build `install-iso` with nixos-generators of a nixosConfiguration
###  - flash ./result/iso/nixos-*.iso
###  - boot and connect to wifi or network
###  - run this script form the build host with following values changed to met your use case
###
### Known Defects
###  - as currently built to only handle a single disk
###  - script can't yet pull data from derivation to get data about disks
###  - wipeing filesystem data assums only 2 partitions with {1,2,}
###
### Special thanks to Brian McGee
### https://bmcgee.ie/posts/2022/12/setting-up-my-new-laptop-nix-style/

# nixosConfiguration
FLAKE="$1"

# Ip Address or Hostname of INSTALL TARGET
HOST="$2"

# User on the INSTALL TARGET nix is going to talk to
HOST_USER="root"

# Feed the Beast
DEVICE="/dev/sda"

# NIX signing key
KEY_FILE="$HOME/Projects/secrets/reg-nix-secret-key"

# Name of the ZFS pool
ZPOOL="zroot_${HOST}"

# Collect password for disk encryption
collect-password() {
  echo "Collecting password for disk encryption on $DEVICE"
  while true; do
    echo "Please enter a password: "
    read -s first
    read -s -p "Retype a password: " second
    if [ $first == $second ];
    then
      password=$first
      echo "Both passwords are the same. Continuing.."
      echo "$password" | ssh $HOST_USER@$HOST "cat > /tmp/disk.key"
    else
      echo "You have entered different passwords. Try again.."
      continue
    fi
    break
  done

}

main () {

  collect-password

  # TODO use tmp dir
  cd ~

  echo "Build $FLAKE"
  nixos-rebuild build --flake ~/dotfiles#${FLAKE} || exit $?

  echo "Sign $FLAKE"
  nix store sign --key-file $KEY_FILE --recursive ~/result || exit $?

  SYSTEM=$(readlink ~/result) 
  # Get path to create and mount scripts
  CREATE="$(cat ${SYSTEM}/sw/bin/disko-create)";
  MOUNT="$(cat ${SYSTEM}/sw/bin/disko-mount)";

  echo "Copy Disk Creation and Mounting scripts to $HOST"
  scp $CREATE ${HOST_USER}@${HOST}:~/disko-create
  scp $MOUNT ${HOST_USER}@${HOST}:~/disko-mount

  echo "Unmount $DEVICE" 
  ssh $HOST_USER@$HOST -t "sh -c 'umount -R /mnt'"

  # When continously reformatting the same disk all the filesystems would
  # realign with their prior location resulting in errors. Best try and wipe
  # away any superblocks and other metadata that we can find.
  echo "Wipe $DEVICE" 
  # will attempt to wipe hints from each partition then the whole partition table
  ssh $HOST_USER@$HOST -t "sh -c 'wipefs -fa ${DEVICE}{1,2,3,4,}'"

  echo "Run Disko Create: $CREATE" 
  ssh $HOST_USER@$HOST -t "sh -c './disko-create'" || exit $?

  echo "Run Disko Mount: $MOUNT" 
  ### need to copy over machine-id and figure out how it assosiates to the zpool
  ssh $HOST_USER@$HOST -t "sh -c './disko-mount'" || exit $?

  echo "Copy $FLAKE to $DEVICE on $HOST"
  nix copy --to "ssh://$HOST_USER@$HOST?remote-store=local?root=/mnt" ~/result || exit $?

  echo "Install $FLAKE on $HOST" 
  ssh $HOST_USER@$HOST -t "sh -c 'nixos-install --no-root-passwd --no-channel-copy --system ${SYSTEM}'" || exit $?

  echo "Unmount $DEVICE";
  ssh $HOST_USER@$HOST -t "sh -c 'umount -R /mnt'"

  # install media machine-id likely doesn't match installed machine. Thus we
  # need to export the zpool so it can be imported on boot.
  # @TODO fix this?
  echo "Export zpool $ZPOOL";
  ssh $HOST_USER@$HOST -t "sh -c 'zpool export ${ZPOOL}'"
}

main
