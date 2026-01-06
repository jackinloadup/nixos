{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkEnableOption getExe;
  cfg = config.machine.kexec;

  # Core script to list generations with details (for CLI/fzf)
  # Format: "NUM MARKER DATE NixOS VERSION kernel KERNEL" where NUM is always first for easy parsing
  listGenerations = pkgs.writeShellScript "list-nixos-generations" ''
    PROFILE_DIR="/nix/var/nix/profiles"

    # Get the current default generation number
    current=$(readlink "$PROFILE_DIR/system" | sed 's/system-\([0-9]*\)-link/\1/')

    # List all generations
    for gen in "$PROFILE_DIR"/system-*-link; do
      [ -e "$gen" ] || continue

      num=$(basename "$gen" | sed 's/system-\([0-9]*\)-link/\1/')
      date=$(stat -c '%y' "$gen" | cut -d' ' -f1)

      # Get NixOS version
      if [ -f "$gen/nixos-version" ]; then
        nixos_ver=$(cat "$gen/nixos-version")
      else
        nixos_ver="unknown"
      fi

      # Get kernel version from the kernel path
      kernel_path=$(readlink -f "$gen/kernel")
      kernel_ver=$(basename "$(dirname "$kernel_path")" | sed 's/.*linux-//')

      # Mark current with asterisk
      if [ "$num" = "$current" ]; then
        marker="*"
      else
        marker=" "
      fi

      # Put generation number first for easy awk extraction
      printf "%s %s  %s  NixOS %s  kernel %s\n" "$num" "$marker" "$date" "$nixos_ver" "$kernel_ver"
    done | sort -k1 -rn
  '';

  # Core kexec function
  kexecGeneration = pkgs.writeShellScript "kexec-generation" ''
    set -euo pipefail

    gen_num="$1"
    PROFILE_DIR="/nix/var/nix/profiles"

    if [ "$gen_num" = "current" ]; then
      gen_path="$PROFILE_DIR/system"
    else
      gen_path="$PROFILE_DIR/system-''${gen_num}-link"
    fi

    if [ ! -e "$gen_path" ]; then
      echo "Error: Generation $gen_num not found" >&2
      exit 1
    fi

    echo "Loading generation $gen_num into kexec..."

    # Build command line: kernel-params + init path
    # The bootloader normally adds init=, but kernel-params doesn't include it
    cmdline="init=$gen_path/init $(cat "$gen_path/kernel-params")"

    echo "Kernel: $gen_path/kernel"
    echo "Initrd: $gen_path/initrd"
    echo "Cmdline: $cmdline"

    # Load the kernel
    ${pkgs.kexec-tools}/bin/kexec -l "$gen_path/kernel" \
      --initrd="$gen_path/initrd" \
      --command-line="$cmdline"

    echo "Executing kexec reboot..."
    systemctl kexec
  '';

  # CLI script with fzf
  kexecCli = pkgs.writeShellScriptBin "kexec-reboot" ''
    set -euo pipefail

    echo "Available NixOS generations (* = current default):"
    echo ""

    # Let user select with fzf
    selected=$(${listGenerations} | ${getExe pkgs.fzf} --height=20 --reverse --header="Select generation to boot (Enter to confirm, Esc to cancel)")

    if [ -z "$selected" ]; then
      echo "Cancelled"
      exit 0
    fi

    # Extract generation number (first field)
    gen_num=$(echo "$selected" | awk '{print $1}')

    echo ""
    echo "Selected: $selected"
    echo ""
    read -p "Kexec reboot into generation $gen_num? [y/N] " confirm

    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
      exec sudo ${kexecGeneration} "$gen_num"
    else
      echo "Cancelled"
    fi
  '';
in
{
  options.machine.kexec = {
    enable = mkEnableOption "Enable kexec quick reboot functionality";
  };

  config = mkIf cfg.enable {
    # Ensure kexec-tools is available
    environment.systemPackages = [
      kexecCli
      pkgs.kexec-tools
    ];

    # Polkit rule to allow wheel users to run kexec without password
    security.polkit.enable = true;
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.policykit.exec" &&
            action.lookup("program") == "${kexecGeneration}" &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
