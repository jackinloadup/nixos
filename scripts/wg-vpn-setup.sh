#!/usr/bin/env bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

# Make sure script works from correct root
cd $PROGDIR || exit 1

MACHINE=$1
FOLDER="secrets/machines/$MACHINE/wg-vpn"

if [ -z "$1" ]; then
  echo "Create wg secrets for <machine>"
  echo "Usage: $PROGNAME <machine>"
  exit 1
fi

# Ensure the relevant folders are created
mkdir -p $FOLDER

# Generate and store private key in variable
PRIVATE_KEY=$(wg genkey)

# Encrypt private key
echo "$PRIVATE_KEY" | ragenix --editor - -e "$FOLDER/private.age"

# Generate and encrypt public key
echo "$PRIVATE_KEY" | wg pubkey | ragenix --editor - -e "$FOLDER/public.age"

# cat private.key | ragenix --editor - -e secrets/machines/obsdian/wg-vpn/private.age
