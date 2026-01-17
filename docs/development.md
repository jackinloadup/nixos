# Development Workflow

This document covers the development workflow for working with this NixOS configuration.

## Quick Start

```bash
# Enter development shell
nix develop

# Format code
nix fmt

# Check for issues
nix flake check

# Build a specific machine
nix build .#nixosConfigurations.<machine>.config.system.build.toplevel
```

## Development Shell

The default development shell includes:
- `nixpkgs-fmt` - Nix code formatter
- `statix` - Nix linter (anti-pattern detection)
- `deadnix` - Find unused Nix code
- Pre-commit hooks (auto-installed)

```bash
# Enter default shell
nix develop

# Enter specific shells
nix develop .#secrets  # For managing encrypted secrets
nix develop .#rust     # Rust development
nix develop .#hack     # Security tools
```

## Pre-commit Hooks

The development shell automatically installs git pre-commit hooks:

- **treefmt** - Auto-format Nix files
- **deadnix** - Detect unused code

Hooks run automatically on `git commit`. To skip (not recommended):
```bash
git commit --no-verify
```

## Code Formatting

Format all Nix files:
```bash
nix fmt
```

The formatter uses:
- `nixpkgs-fmt` for Nix formatting
- `deadnix` for removing unused code
- `statix` for linting

## Checking Configuration

### Full check
```bash
nix flake check
```

This runs:
- Nix evaluation of all configurations
- NixVim configuration tests
- Builds all machine configurations (toplevel)

### Check specific machine
```bash
nix build .#nixosConfigurations.zen.config.system.build.toplevel --dry-run
```

## Building

### Build a machine locally
```bash
# Dry run (check if it builds)
nixos-rebuild build --flake .#<machine>

# Build and switch (local machine)
sudo nixos-rebuild switch --flake .#<machine>
```

### Build for remote machine
```bash
# Build locally, deploy remotely
nixos-rebuild switch --flake .#<machine> --target-host root@<hostname>

# With SSH options
NIX_SSHOPTS="-t" nixos-rebuild boot --flake .#<machine> --target-host root@<hostname>
```

### Build install ISO
```bash
nix build .#install-iso
```

## Updating Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Show what changed
nix flake metadata
```

## Testing in VM

```bash
# Build and run VM for a machine
nixos-rebuild build-vm --flake .#<machine>
./result/bin/run-<machine>-vm

# Or use nixos-anywhere's VM test
nix run github:nix-community/nixos-anywhere -- --flake .#<machine> --vm-test
```

Note: VM testing requires disabling disk encryption in the configuration.

## Nix REPL

Interactive exploration of the flake:

```bash
nix repl
:lf .
# Now you can explore:
# nixosConfigurations.zen.config.services
# etc.
```

Or use the helper:
```bash
nix repl ./repl.nix
```

## Directory Navigation with direnv

The repo uses direnv (`.envrc`) to automatically load the development shell:

```bash
# Allow direnv for this directory
direnv allow

# Shell loads automatically when entering directory
cd ~/Projects/nixos
# Development tools are now available
```

## Common Tasks

### Add a new package to a machine
1. Edit `machines/<name>/configuration.nix`
2. Add to `environment.systemPackages` or relevant option
3. Build and test: `nixos-rebuild build --flake .#<name>`

### Add a new module
1. Create module in `modules/nixos/<name>/default.nix`
2. Import in `modules/nixos/default.nix`
3. Add to appropriate module group (common, linux, server, etc.)

### Add a new machine
See [NEW-MACHINE.md](../NEW-MACHINE.md)

### Manage secrets
See [secrets.md](secrets.md)
