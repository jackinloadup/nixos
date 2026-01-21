{ pkgs }:
pkgs.writeShellApplication {
  name = "provision-secrets";

  runtimeInputs = with pkgs; [
    openssh # ssh-keygen
    wireguard-tools # wg
    nebula # nebula-cert
    ragenix # ragenix
    coreutils # mktemp, rm, etc.
  ];

  text = ''
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'

    SECRETS_DST="secrets/machines"
    DEVICES_DST="secrets/devices"
    NEBULA_CA="secrets/services/nebula"

    # Decrypt age file using SSH key
    age_decrypt() {
      local file=$1
      if [ -z "$IDENTITY" ]; then
        echo -e "''${RED}No identity specified. Use --identity/-i or set default key.''${NC}" >&2
        return 1
      fi
      if [ ! -f "$IDENTITY" ]; then
        echo -e "''${RED}Identity file not found: $IDENTITY''${NC}" >&2
        return 1
      fi
      if $DEBUG; then
        echo -e "''${BLUE}[DEBUG] Decrypting: $file''${NC}" >&2
        echo -e "''${BLUE}[DEBUG] Identity: $IDENTITY''${NC}" >&2
        echo -e "''${BLUE}[DEBUG] Identity file type: $(file "$IDENTITY")''${NC}" >&2
        echo -e "''${BLUE}[DEBUG] Identity first line: $(head -1 "$IDENTITY")''${NC}" >&2
        echo -e "''${BLUE}[DEBUG] Running: age -d -i $IDENTITY $file''${NC}" >&2
      fi
      age -d -i "$IDENTITY" "$file"
    }

    usage() {
      cat <<EOF
    Usage: provision-secrets <name> [OPTIONS]

    Generate and encrypt secrets for a new machine or device.

    Machine Options (NixOS hosts):
      --all                Generate all secret types
      --ssh                Generate SSH host key
      --init-ssh           Generate init SSH host key
      --wireguard          Generate WireGuard keys
      --nebula             Generate Nebula certificate (new keypair)
      --nebula-ip IP       Nebula IP address (e.g., 10.101.0.X/24)
      --force              Overwrite existing secrets

    Device Options (phones, external clients):
      --sign-device        Sign an existing public key for a device
      --pubkey FILE        Path to device's public key file
      --nebula-ip IP       Nebula IP address (e.g., 10.101.0.X/24)

    General:
      -i, --identity FILE  SSH private key for age decryption (default: ~/.ssh/id_ed25519)
      --debug              Show debug information
      -h, --help           Show this help

    Examples:
      # NixOS machine - generate all secrets
      provision-secrets newmachine --all --nebula-ip 10.101.0.15/24

      # NixOS machine - specific secrets
      provision-secrets newmachine --wireguard --nebula --nebula-ip 10.101.0.15/24

      # NixOS machine - interactive mode
      provision-secrets newmachine

      # Mobile device - sign existing public key
      provision-secrets lucas-phone --sign-device --pubkey ~/phone.pub --nebula-ip 10.101.0.20/24
    EOF
      exit 0
    }

    generate_ssh() {
      local machine=$1
      local type=$2 # "sshd" or "init-sshd"
      local folder="$SECRETS_DST/$machine/$type"

      if [ -f "$folder/private_key.age" ] && [ -z "''${FORCE:-}" ]; then
        echo -e "''${YELLOW}[$type] Keys already exist - skipping (use --force to overwrite)''${NC}"
        return 0
      fi

      mkdir -p "$folder"
      local tmpkey
      tmpkey=$(mktemp)

      ssh-keygen -t ed25519 -f "$tmpkey" -N "" -C "$machine" -q

      cat "$tmpkey" | ragenix --editor - -e "$folder/private_key.age"
      cp "''${tmpkey}.pub" "$folder/public_key"
      rm -f "$tmpkey" "''${tmpkey}.pub"

      echo -e "''${GREEN}[$type] Generated host key''${NC}"
      echo "  Public key: $(cat "$folder/public_key")"
    }

    generate_wireguard() {
      local machine=$1
      local folder="$SECRETS_DST/$machine/wg-vpn"

      if [ -f "$folder/private.age" ] && [ -z "''${FORCE:-}" ]; then
        echo -e "''${YELLOW}[WireGuard] Keys already exist - skipping''${NC}"
        return 0
      fi

      mkdir -p "$folder"

      local private_key
      private_key=$(wg genkey)
      local public_key
      public_key=$(echo "$private_key" | wg pubkey)

      echo "$private_key" | ragenix --editor - -e "$folder/private.age"
      echo "$public_key" | ragenix --editor - -e "$folder/public.age"

      echo -e "''${GREEN}[WireGuard] Generated keys''${NC}"
      echo "  Public key: $public_key"
      echo "  Add to modules/nixos/gumdrop/vpn.nix peers"
    }

    generate_nebula() {
      local machine=$1
      local nebula_ip=$2
      local folder="$SECRETS_DST/$machine/nebula"

      if [ -z "$nebula_ip" ]; then
        read -rp "Enter Nebula IP for $machine (e.g., 10.101.0.X/24): " nebula_ip
      fi

      if [ -f "$folder/host.crt.age" ] && [ -z "''${FORCE:-}" ]; then
        echo -e "''${YELLOW}[Nebula] Cert already exists - skipping''${NC}"
        return 0
      fi

      if [ ! -f "$NEBULA_CA/ca.key.age" ]; then
        echo -e "''${RED}[Nebula] CA not found at $NEBULA_CA/ca.key.age''${NC}"
        echo "  Initialize CA first with:"
        echo "    nebula-cert ca -name 'Gumdrop Nebula CA'"
        echo "    cat ca.key | ragenix --editor - -e $NEBULA_CA/ca.key.age"
        echo "    cat ca.crt | ragenix --editor - -e $NEBULA_CA/ca.crt.age"
        return 1
      fi

      mkdir -p "$folder"

      local tmpdir
      tmpdir=$(mktemp -d)
      # shellcheck disable=SC2064
      trap "rm -rf $tmpdir" EXIT

      age_decrypt "$NEBULA_CA/ca.key.age" >"$tmpdir/ca.key"
      age_decrypt "$NEBULA_CA/ca.crt.age" >"$tmpdir/ca.crt"

      nebula-cert sign \
        -ca-crt "$tmpdir/ca.crt" \
        -ca-key "$tmpdir/ca.key" \
        -name "$machine" \
        -ip "$nebula_ip" \
        -out-crt "$tmpdir/$machine.crt" \
        -out-key "$tmpdir/$machine.key"

      cat "$tmpdir/$machine.crt" | ragenix --editor - -e "$folder/host.crt.age"
      cat "$tmpdir/$machine.key" | ragenix --editor - -e "$folder/host.key.age"

      echo -e "''${GREEN}[Nebula] Generated certificate ($nebula_ip)''${NC}"
    }

    sign_device() {
      local device=$1
      local pubkey_file=$2
      local nebula_ip=$3
      local folder="$DEVICES_DST/$device"

      if [ -z "$pubkey_file" ]; then
        echo -e "''${RED}[Device] --pubkey is required for --sign-device''${NC}"
        exit 1
      fi

      if [ ! -f "$pubkey_file" ]; then
        echo -e "''${RED}[Device] Public key file not found: $pubkey_file''${NC}"
        exit 1
      fi

      if [ -z "$nebula_ip" ]; then
        read -rp "Enter Nebula IP for $device (e.g., 10.101.0.X/24): " nebula_ip
      fi

      if [ -f "$folder/host.crt.age" ] && [ -z "''${FORCE:-}" ]; then
        echo -e "''${YELLOW}[Device] Certificate already exists - skipping (use --force to overwrite)''${NC}"
        return 0
      fi

      if [ ! -f "$NEBULA_CA/ca.key.age" ]; then
        echo -e "''${RED}[Device] CA not found at $NEBULA_CA/ca.key.age''${NC}"
        return 1
      fi

      mkdir -p "$folder"

      # Copy public key to device folder
      cp "$pubkey_file" "$folder/public_key"

      local tmpdir
      tmpdir=$(mktemp -d)
      # shellcheck disable=SC2064
      trap "rm -rf $tmpdir" EXIT

      age_decrypt "$NEBULA_CA/ca.key.age" >"$tmpdir/ca.key"
      age_decrypt "$NEBULA_CA/ca.crt.age" >"$tmpdir/ca.crt"

      nebula-cert sign \
        -ca-crt "$tmpdir/ca.crt" \
        -ca-key "$tmpdir/ca.key" \
        -name "$device" \
        -ip "$nebula_ip" \
        -in-pub "$folder/public_key" \
        -out-crt "$tmpdir/$device.crt"

      # Encrypt the certificate with ragenix
      cat "$tmpdir/$device.crt" | ragenix --editor - -e "$folder/host.crt.age"

      echo -e "''${GREEN}[Device] Signed certificate for $device ($nebula_ip)''${NC}"
      echo ""
      echo -e "''${BLUE}To transfer to device, decrypt the files:''${NC}"
      echo "  age -d -i $IDENTITY $folder/host.crt.age > host.crt"
      echo "  age -d -i $IDENTITY secrets/services/nebula/ca.crt.age > ca.crt"
      echo ""
      echo -e "''${BLUE}Then import host.crt and ca.crt into the Nebula app.''${NC}"
    }

    interactive_mode() {
      local machine=$1

      echo "Setting up secrets for: $machine"
      echo ""

      read -rp "Generate SSH host key? [Y/n]: " do_ssh
      read -rp "Generate init SSH host key? [y/N]: " do_init_ssh
      read -rp "Generate WireGuard keys? [Y/n]: " do_wg
      read -rp "Generate Nebula certificate? [Y/n]: " do_nebula

      [[ ! "$do_ssh" =~ ^[Nn]$ ]] && generate_ssh "$machine" "sshd"
      [[ "$do_init_ssh" =~ ^[Yy]$ ]] && generate_ssh "$machine" "init-sshd"
      [[ ! "$do_wg" =~ ^[Nn]$ ]] && generate_wireguard "$machine"
      [[ ! "$do_nebula" =~ ^[Nn]$ ]] && generate_nebula "$machine" ""
    }

    # Main
    NAME=""
    NEBULA_IP=""
    PUBKEY_FILE=""
    IDENTITY="$HOME/.ssh/id_ed25519"
    DEBUG=false
    DO_SSH=false
    DO_INIT_SSH=false
    DO_WG=false
    DO_NEBULA=false
    DO_ALL=false
    DO_SIGN_DEVICE=false
    FORCE=""

    while [[ $# -gt 0 ]]; do
      case $1 in
      -h | --help) usage ;;
      --all)
        DO_ALL=true
        shift
        ;;
      --ssh)
        DO_SSH=true
        shift
        ;;
      --init-ssh)
        DO_INIT_SSH=true
        shift
        ;;
      --wireguard)
        DO_WG=true
        shift
        ;;
      --nebula)
        DO_NEBULA=true
        shift
        ;;
      --nebula-ip)
        NEBULA_IP="$2"
        shift 2
        ;;
      --sign-device)
        DO_SIGN_DEVICE=true
        shift
        ;;
      --pubkey)
        PUBKEY_FILE="$2"
        shift 2
        ;;
      -i | --identity)
        IDENTITY="$2"
        shift 2
        ;;
      --debug)
        DEBUG=true
        shift
        ;;
      --force)
        FORCE=1
        shift
        ;;
      -*)
        echo "Unknown option: $1"
        exit 1
        ;;
      *)
        NAME="$1"
        shift
        ;;
      esac
    done

    if [ -z "$NAME" ]; then
      usage
    fi

    # Device signing mode
    if $DO_SIGN_DEVICE; then
      echo "Signing device certificate for: $NAME"
      sign_device "$NAME" "$PUBKEY_FILE" "$NEBULA_IP"
      echo ""
      echo "=== Done ==="
      echo "Device files created in: $DEVICES_DST/$NAME/"
      exit 0
    fi

    # Machine provisioning mode
    echo "Provisioning secrets for: $NAME"
    mkdir -p "$SECRETS_DST/$NAME"

    if $DO_ALL; then
      generate_ssh "$NAME" "sshd"
      generate_wireguard "$NAME"
      generate_nebula "$NAME" "$NEBULA_IP"
    elif $DO_SSH || $DO_INIT_SSH || $DO_WG || $DO_NEBULA; then
      $DO_SSH && generate_ssh "$NAME" "sshd"
      $DO_INIT_SSH && generate_ssh "$NAME" "init-sshd"
      $DO_WG && generate_wireguard "$NAME"
      $DO_NEBULA && generate_nebula "$NAME" "$NEBULA_IP"
    else
      interactive_mode "$NAME"
    fi

    echo ""
    echo "=== Done ==="
    echo "Secrets created in: $SECRETS_DST/$NAME/"
  '';
}
