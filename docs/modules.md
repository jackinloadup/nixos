# NixOS Modules

This flake exposes reusable `nixosModules` that can be imported into machine configurations.

## Available Modules

### Core Modules

| Module | Description |
|--------|-------------|
| `default` | Full default configuration (common + linux + tui + gui + gumdrop) |
| `common` | Browser, Bluetooth, Solo2, Yubikey, secrets |
| `linux` | Core Linux config (boot-tor, k3s, machine settings, services) |

### Environment Modules

| Module | Description |
|--------|-------------|
| `tui` | Terminal environment (tmux, zsh) |
| `gui` | Graphical environment (Stylix theming, monitor backlight control) |

### Window Manager Modules

| Module | Description |
|--------|-------------|
| `windowManagers` | All window managers combined (Hyprland, Niri, Sway) |
| `hyprland` | Hyprland compositor only |
| `i3` | i3 window manager only |
| `niri` | Niri compositor only |
| `sway` | Sway compositor only |

### Feature Modules

| Module | Description |
|--------|-------------|
| `server` | Server services (Nextcloud, Home Assistant, Postgres, Hydra, NixVirt) |
| `services` | Common services (Searx, Smokeping, Docker, Syncthing, Vaultwarden) |
| `gaming` | Steam and gaming tools |
| `radio` | SDR/software-defined radio tools |
| `crypto` | Cryptocurrency tools |
| `work` | Work-related tools (Obsidian) |

### Machine-Specific Modules

| Module | Description |
|--------|-------------|
| `gumdrop` | Gumdrop network configuration (VPN, storage mounts, printer/scanner) |

### User Modules

| Module | Description |
|--------|-------------|
| `lriutzelTui` | lriutzel's TUI-only configuration |
| `lriutzelGui` | lriutzel's GUI configuration |
| `lriutzelFull` | lriutzel's full configuration (TUI + GUI) |
| `criutzel` | criutzel's user configuration |
| `kodi` | Kodi media center user |

## Usage

Import modules in your machine's `configuration.nix`:

```nix
{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.default      # Full default setup
    inputs.self.nixosModules.lriutzelFull # User config
    inputs.self.nixosModules.gaming       # Add gaming support
    ./hardware-configuration.nix
  ];

  # Machine-specific configuration...
}
```

## Module Composition

The `default` module is composed of:
- `common` - Base configuration
- `linux` - Linux-specific settings
- `tui` - Terminal tools
- `gui` - Graphical environment
- `gumdrop` - Network/storage integration

For minimal/headless servers, import individual modules:

```nix
imports = [
  inputs.self.nixosModules.common
  inputs.self.nixosModules.linux
  inputs.self.nixosModules.tui
  inputs.self.nixosModules.server
];
```

## Module Locations

- NixOS modules: `modules/nixos/`
- Home-manager modules: `modules/home-manager/`
- Module entry point: `modules/nixos/default.nix`
