# Repository Structure

This document explains the directory layout of the NixOS configuration repository.

```
nixos/
├── machines/          # Per-host NixOS configurations
├── modules/           # Reusable NixOS and home-manager modules
│   ├── nixos/         # NixOS system modules
│   ├── home-manager/  # User environment modules
│   ├── nixvim/        # Neovim configuration (basic & full)
│   └── syncthing/     # Syncthing device/folder definitions
├── profiles/          # Hardware and disk profiles (disko configs)
├── users/             # User account configurations
├── secrets/           # Encrypted secrets (agenix/ragenix)
│   ├── machines/      # Per-machine secrets (SSH host keys)
│   ├── services/      # Service credentials
│   ├── system/        # System-level secrets
│   └── users/         # User passwords and keys
├── scripts/           # Helper shell scripts
├── overlays/          # Nixpkgs overlays
├── packages/          # Custom package definitions
├── shells/            # Development shells (nix develop)
├── lib/               # Helper Nix functions
├── templates/         # Flake templates for new machines/shells
├── patches/           # Kernel and package patches
├── assets/            # Static assets
└── settings/          # Shared settings
```

## Key Files

| File | Purpose |
|------|---------|
| `flake.nix` | Main flake definition, inputs, and outputs |
| `flake.lock` | Pinned dependency versions |
| `nixos-secrets.nix` | Agenix secret declarations for NixOS |
| `secrets.nix` | Secret path definitions |
| `insecure-packages.nix` | Allowed insecure packages |
| `vm.nix` | VM testing configuration |
| `repl.nix` | Nix REPL helper |

## Directory Details

### `machines/`
Each subdirectory represents a host. Contains:
- `configuration.nix` - Main system configuration
- `hardware-configuration.nix` - Hardware-specific settings (disko, hostId)
- Optional: per-machine modules, user overrides

### `modules/`
Reusable configuration modules exposed as `nixosModules` in the flake. See [modules.md](modules.md) for details.

### `profiles/`
Hardware profiles and disko disk layouts:
- `disk-*.nix` - Disk partitioning schemes (laptop, workstation, bcachefs)
- `amd.nix`, `intel.nix` - CPU-specific settings
- `zfs.nix` - ZFS configuration

### `users/`
User account definitions with home-manager configurations. Each user can have:
- Base configuration
- Desktop-specific settings (GNOME, etc.)
- Per-machine overrides

### `secrets/`
Encrypted with agenix/ragenix. Structure mirrors what the secrets protect:
- `machines/<name>/sshd/` - SSH host keys
- `services/<name>/` - Service credentials
- `users/<name>/` - User passwords

### `shells/`
Development environments accessible via `nix develop .#<name>`:
- `default` - Main dev shell with formatting tools
- `secrets` - Shell with ragenix for managing secrets
- `rust` - Rust development environment
- `hack` - Security/hacking tools

### `templates/`
Flake templates for bootstrapping:
- `machine` - New machine configuration
- `shell` - New development shell with direnv
