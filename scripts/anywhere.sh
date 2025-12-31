#!/usr/bin/env bash

# strict
set -euo pipefail

# debug
set -x

readonly PROGNAME="$(basename "$0")"


main() {
  local HOST="$1"
  local ADDRESS="$2"
  local KEY="$3"
  local REMOTE_USER="$4"
  #local FLAKE="github:jackinloadup/nixos"
  local FLAKE="."

  usage

  # Create a temporary directory
  secrets_dir=$(mktemp -d)
  disk_key_file=$(mktemp)

  # Function to cleanup temporary directory on exit
  trap cleanup EXIT

  # get disk password
  read -p "Enter disk password: " disk_pass
  echo "${disk_pass}" > $disk_key_file

  # Create the directory where sshd expects to find the host keys
  install -d -m755 "${secrets_dir}/etc/ssh"

  # Decrypt your private key from the password store and copy it to the temporary directory
  age \
    -i ${KEY} \
    -d secrets/machines/${HOST}/sshd/private_key.age \
    > "${secrets_dir}/etc/ssh/ssh_host_ed25519_key"


  # Set the correct permissions so sshd will accept the key
  chmod 600 "${secrets_dir}/etc/ssh/ssh_host_ed25519_key"

  # deploy wallpapers the sad manual way
  install -d -m755 "${secrets_dir}/home/lriutzel/Pictures/Wallpapers"
  cp -r /home/lriutzel/Pictures/Wallpapers/* "${secrets_dir}/home/lriutzel/Pictures/Wallpapers"
  cp -r /home/lriutzel/Pictures/background.jpg "${secrets_dir}/home/lriutzel/Pictures/background.jpg"

  # Install NixOS to the host system with our secrets
  nix run github:nix-community/nixos-anywhere -- \
    --build-on local \
    --extra-files "${secrets_dir}" \
    --flake "${FLAKE}#${HOST}" \
    -i ${KEY} \
    --disk-encryption-keys /tmp/disk.key $disk_key_file \
    --target-host ${REMOTE_USER}@${ADDRESS}
}

usage() {
   echo "Usage: $PROGNAME networkAddress hostname key"
   echo "ex: $PROGNAME darpa 192.168.1.123 ~/.ssh/id_rsa"

   if [ -z "$HOST" ]; then
       echo "No argument supplied"
       echo "Please supply the network address to get to the machine"
       echo "as well as the hostname associated with the secrets"
       exit 1
  fi

   if [ -z "$ADDRESS" ]; then
       echo "No network address detected"
       exit 1
   fi

   if [ -z "$KEY" ]; then
       echo "No key detected"
       exit 1
   fi
}

cleanup() {
  rm -rf "$secrets_dir"
  rm -rf "$disk_key_file"
}

main "$@"
