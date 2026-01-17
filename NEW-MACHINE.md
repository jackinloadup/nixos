# Adding a New Machine

## 1. Create Configuration

```bash
mkdir machines/<name>
cd machines/<name>
nix flake init --template github:jackinloadup/nixos#machine
```

This creates:
- `configuration.nix` - Main system configuration
- `hardware-configuration.nix` - Hardware/disk settings
- `modules.nix` - Module imports

## 2. Configure the Machine

Edit the generated files:

```bash
# Define machine type and modules to import
vim configuration.nix

# Define disk layout and hardware settings
vim hardware-configuration.nix
```

Generate a unique hostId (required for ZFS):
```bash
head -c4 /dev/urandom | od -A none -t x4
```

## 3. Add Secrets

Public keys must be in place for ragenix encryption to work.

```bash
# Enter secrets shell
nix develop .#secrets

# Create directory for machine secrets
mkdir -p secrets/machines/<name>/sshd

# Generate SSH host keys
ssh-keygen -t ed25519 -f secrets/machines/<name>/sshd/ssh_host_ed25519_key -N ""

# Add public key to secrets.nix
vim secrets.nix

# Re-encrypt all secrets with new key
./scripts/encrypt.sh
```

## 4. Build and Deploy

### Option A: nixos-anywhere (recommended for new machines)

```bash
# Boot target machine with NixOS ISO
# Set password and note IP address

# From existing machine:
nix run github:nix-community/nixos-anywhere -- \
  --build-on local \
  --flake .#<name> \
  --disk-encryption-keys /tmp/disk.key /tmp/disk.key \
  nixos@<target-ip>
```

### Option B: Manual install

```bash
# On target machine, format disk with disko
sudo nix run github:nix-community/disko -- --mode disko /tmp/disko-config.nix

# Install
sudo nixos-install --flake .#<name>
```

### Option C: Remote rebuild (existing NixOS)

```bash
NIX_SSHOPTS="-t" nixos-rebuild boot --flake .#<name> --target-host root@<hostname>
```

## Template Files

The machine template creates these files:

### configuration.nix
```nix
{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.default
    ./hardware-configuration.nix
  ];

  machine = {
    users = [ "lriutzel" ];
    # ... other options
  };

  system.stateVersion = "25.11";
}
```

### hardware-configuration.nix
```nix
{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ../../profiles/disk-laptop-1.nix  # Choose appropriate profile
  ];

  disko.devices.disk.main.device = "/dev/nvme0n1";
  networking.hostId = "abcd1234";  # Generate unique ID
}
```

## See Also

- [docs/machines.md](docs/machines.md) - Machine overview
- [docs/profiles.md](docs/profiles.md) - Disk and hardware profiles
- [docs/secrets.md](docs/secrets.md) - Secrets management
