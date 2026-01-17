# NixOS Configuration

Personal home lab NixOS setup exposed as a flake.

## Quick Start

```bash
# Enter development shell
nix develop

# Build a machine
nix build .#nixosConfigurations.<machine>.config.system.build.toplevel

# Deploy to local machine
sudo nixos-rebuild switch --flake .#<machine>

# Deploy to remote machine
nixos-rebuild switch --flake .#<machine> --target-host root@<hostname>
```

## Documentation

| Document | Description |
|----------|-------------|
| [Repository Structure](docs/repository-structure.md) | Directory layout and key files |
| [Modules](docs/modules.md) | Available nixosModules |
| [Machines](docs/machines.md) | Machine overview and VPN assignments |
| [Secrets](docs/secrets.md) | Agenix/ragenix secrets management |
| [Development](docs/development.md) | Development workflow and tools |
| [Profiles](docs/profiles.md) | Disk layouts and hardware profiles |
| [Scripts](docs/scripts.md) | Helper scripts |
| [Upgrade Notes](docs/upgrade-notes.md) | Service upgrade procedures |
| [New Machine](NEW-MACHINE.md) | Adding a new machine |

## NixOS Resources

- Local Manual: `man configuration.nix`
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://wiki.nixos.org/wiki/NixOS_Wiki)
- [Package Search](https://search.nixos.org/packages)
- [Options Search](https://search.nixos.org/options)
- [nixos/nixpkgs repo](https://github.com/NixOS/nixpkgs/)

## Home-Manager

- Local Manual: `man home-configuration.nix`
- [Options Reference](https://nix-community.github.io/home-manager/options.html)
- [Repository](https://github.com/nix-community/home-manager)

## Flake Inputs

Projects used in this configuration:

| Project | Purpose |
|---------|---------|
| [impermanence](https://github.com/nix-community/impermanence/) | Ephemeral root filesystem |
| [disko](https://github.com/nix-community/disko) | Declarative disk partitioning |
| [nixos-hardware](https://github.com/NixOS/nixos-hardware) | Hardware quirks |
| [nixos-facter](https://github.com/nix-community/nixos-facter) | Hardware detection |
| [stylix](https://github.com/nix-community/stylix) | System-wide theming |
| [nix-ld](https://github.com/nix-community/nix-ld) | Run unpatched binaries |
| [nixvim](https://github.com/nix-community/nixvim) | Neovim configuration |
| [ucodenix](https://github.com/e-tho/ucodenix/) | AMD microcode updates |
| [nix-flatpak](https://github.com/gmodena/nix-flatpak) | Declarative Flatpak |
| [ragenix](https://github.com/yaxitech/ragenix) | Secrets management |

## Services

Services running on the homelab:

| Service | Description |
|---------|-------------|
| [Home Assistant](https://www.home-assistant.io/) | Home automation |
| [Frigate](https://github.com/blakeblackshear/frigate) | Camera NVR |
| [Adguard Home](https://adguard.com) | Network ad blocking |
| [immich](https://immich.app/) | Photo management |
| [Nextcloud](https://nextcloud.com/) | File sync and sharing |
| [Collabora](https://www.collabora.com/) | Document editing |
| [Vaultwarden](https://github.com/dani-garcia/vaultwarden) | Password manager |
| [Murmur](https://mumble.info/) | Voice chat (Mumble) |
| [WireGuard](https://www.wireguard.com/) | VPN |
| [Syncthing](https://syncthing.net/) | File synchronization |
| [Paperless-ngx](https://docs.paperless-ngx.com/) | Document management |
| [go2rtc](https://github.com/AlexxIT/go2rtc) | Camera streaming |
| [Smokeping](https://oss.oetiker.ch/smokeping/) | Network monitoring |
| [Jellyfin](https://jellyfin.org/) | Media server |

## Install ISO

Build a custom install ISO:

```bash
nix build .#install-iso
```

## Installation

See [NEW-MACHINE.md](NEW-MACHINE.md) for detailed instructions.

### Quick Install with nixos-anywhere

```bash
# Boot target with NixOS ISO, set password, get IP
# From existing machine:
nix run github:nix-community/nixos-anywhere -- \
  --build-on local \
  --flake .#<machine> \
  --disk-encryption-keys /tmp/disk.key /tmp/disk.key \
  nixos@<target-ip>
```

### Test in VM

```bash
# Note: Disable encryption for VM testing
nix run github:nix-community/nixos-anywhere -- --flake .#<machine> --vm-test
```

### Troubleshooting

If mounts don't come up after install:
```bash
sudo systemctl restart systemd-tmpfiles-resetup.service
```
