# Helper Scripts

Utility scripts located in the `scripts/` directory.

## Scripts Overview

| Script | Purpose |
|--------|---------|
| `anywhere.sh` | Deploy NixOS using nixos-anywhere |
| `build-sign-send.sh` | Build, sign, and push to binary cache |
| `fix-bluetooth.sh` | Reset Bluetooth adapter |
| `connect-trackpad.sh` | Connect Bluetooth trackpad |

## Secrets Shell Tools

Secret management tools are available via `nix develop .#secrets`:

| Tool | Purpose |
|------|---------|
| `provision-secrets` | Generate all secrets for a new machine |
| `ragenix` | Encrypt/decrypt individual secrets |

See [secrets.md](secrets.md) for detailed usage.

## Script Details

### anywhere.sh

Wrapper for [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) to deploy NixOS to remote machines.

```bash
./scripts/anywhere.sh <machine> <target-ip>
```

### build-sign-send.sh

Build a NixOS configuration, sign it, and push to a binary cache.

```bash
./scripts/build-sign-send.sh <machine>
```

### fix-bluetooth.sh

Reset the Bluetooth adapter when it stops working.

```bash
./scripts/fix-bluetooth.sh
```

This runs:
```bash
sudo hciconfig hci0 down
sudo rmmod btusb
sudo modprobe btusb
```

### connect-trackpad.sh

Helper to connect a Bluetooth trackpad. Calls `fix-bluetooth.sh` first.

```bash
./scripts/connect-trackpad.sh
```

## Adding New Scripts

1. Create script in `scripts/` directory
2. Make executable: `chmod +x scripts/myscript.sh`
3. Add shebang: `#!/usr/bin/env bash`
4. Consider adding to this documentation
