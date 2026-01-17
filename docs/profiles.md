# Profiles

Hardware profiles and disk layouts in the `profiles/` directory.

## Disk Profiles (Disko)

These profiles define disk partitioning schemes for [disko](https://github.com/nix-community/disko).

### Laptop Profiles

| Profile | Description |
|---------|-------------|
| `disk-laptop-1.nix` | Standard laptop layout with LUKS encryption |
| `disk-laptop-2.nix` | Alternative laptop layout |

### Workstation Profiles

| Profile | Description |
|---------|-------------|
| `disk-workstation.nix` | Standard workstation layout |
| `disk-workstation-2.nix` | Alternative workstation layout |
| `disk-workstation-3.nix` | Third workstation variant |
| `disk-workstation-ext4.nix` | Workstation with ext4 (no ZFS) |

### Special Profiles

| Profile | Description |
|---------|-------------|
| `disk-bcachefs-1.nix` | bcachefs filesystem layout |
| `disk-odroid-n2.nix` | ODROID N2 SBC layout |

## Hardware Profiles

CPU and hardware-specific configurations.

| Profile | Description |
|---------|-------------|
| `amd.nix` | AMD CPU optimizations, microcode, GPU drivers |
| `intel.nix` | Intel CPU settings, microcode |
| `zfs.nix` | ZFS filesystem configuration |
| `bcachefs.nix` | bcachefs support |

### AMD Profile (`amd.nix`)

Includes:
- AMD microcode updates (via ucodenix)
- AMDGPU driver configuration
- ROCm support options
- CPU frequency scaling

### Intel Profile (`intel.nix`)

Includes:
- Intel microcode updates
- Intel GPU configuration

### ZFS Profile (`zfs.nix`)

Includes:
- ZFS kernel module
- ZFS auto-scrub
- Recommended ZFS settings

## Device-Specific Profiles

| Profile | Description |
|---------|-------------|
| `lenovo-m715q.nix` | Lenovo ThinkCentre M715q |
| `chrombox-cn60.nix` | ASUS Chromebox CN60 |
| `pro-art-7800x3d.nix` | ASUS ProArt with Ryzen 7800X3D |
| `mobile-device.nix` | Laptop power management |

## Usage

Import profiles in `hardware-configuration.nix`:

```nix
{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ../../profiles/disk-laptop-1.nix
    ../../profiles/amd.nix
    ../../profiles/zfs.nix
  ];

  # Set the disk device
  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Required for ZFS
  networking.hostId = "abcd1234";
}
```

## Generating hostId

Required for ZFS:

```bash
head -c4 /dev/urandom | od -A none -t x4
```

## Disk Layout Example

Typical laptop layout (`disk-laptop-1.nix`):

```
/dev/nvme0n1
├── p1: EFI System Partition (512MB, FAT32) -> /boot
└── p2: LUKS encrypted
    └── ZFS pool
        ├── root    -> / (ephemeral)
        ├── nix     -> /nix
        ├── persist -> /persist (survives rebuilds)
        └── home    -> /home
```

## Impermanence

Many profiles support impermanence (ephemeral root):
- Root filesystem is reset on each boot
- Persistent data stored in `/persist`
- Configured via `machine.impermanence = true`

See the impermanence module at `modules/nixos/machine/impermanence.nix`.
