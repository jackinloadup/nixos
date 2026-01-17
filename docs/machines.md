# Machines

Overview of all configured machines in the homelab.

## Machine List

| Machine | Type | User | Description |
|---------|------|------|-------------|
| **marulk** | Server | lriutzel | Main home server - DNS, Home Assistant, Frigate NVR, Nextcloud, Vaultwarden, Adguard, Immich, Searx, Smokeping, Murmur, Paperless |
| **reg** | Workstation | lriutzel | Primary development workstation - gaming, full GUI, Niri WM, Technitium DNS |
| **riko** | Laptop | lriutzel | Laptop with fingerprint reader, gaming support, Niri WM |
| **zen** | Workstation | criutzel | Desktop workstation - GNOME, Hyprland, impermanence |
| **kanye** | Laptop | criutzel | Laptop - GNOME desktop, Yubikey support |
| **jesus** | Desktop | multi-user | Shared desktop for lriutzel + criutzel, GNOME |
| **obsidian** | Laptop | lriutzel | Work laptop for Obsidian Systems - Niri/Hyprland, AI tools |
| **timberlake** | Server | - | Secondary server - Jellyfin media server, Home Assistant |
| **lyza** | Server | - | Headless server - Home Assistant, Frigate NVR, ESPHome |
| **nat** | HTPC | kodi | Kodi media center for TV |
| **gumdrop-nas** | NAS | - | Network attached storage |
| **minimal** | Test | - | Minimal test configuration |

## VPN IP Assignments

All machines connect via WireGuard VPN (`vpn.lucasr.com:51820`):

| Machine | VPN IP |
|---------|--------|
| riko | 10.100.0.3/24 |
| lyza | 10.100.0.4/24 |
| kanye | 10.100.0.5/24 |
| zen | 10.100.0.6/24 |
| timberlake | 10.100.0.8/24 |
| nat | 10.100.0.9/24 |
| reg | 10.100.0.11/24 |
| obsidian | 10.100.0.13/24 |
| marulk | VPN server |

## Machine Categories

### Servers (Headless)
- **marulk** - Primary server, runs most services
- **lyza** - Secondary server, Home Assistant + Frigate
- **timberlake** - Media server (Jellyfin)
- **gumdrop-nas** - Storage

### Workstations (Full GUI)
- **reg** - lriutzel's main workstation
- **zen** - criutzel's workstation

### Laptops
- **riko** - lriutzel's laptop (fingerprint, gaming)
- **kanye** - criutzel's laptop
- **obsidian** - Work laptop
- **jesus** - Shared laptop

### Special Purpose
- **nat** - Kodi HTPC
- **minimal** - Testing

## Adding a New Machine

See [NEW-MACHINE.md](../NEW-MACHINE.md) for instructions on creating a new machine configuration.

## Machine Configuration Structure

Each machine directory typically contains:

```
machines/<name>/
├── configuration.nix        # Main config, imports modules
├── hardware-configuration.nix  # Disko layout, hostId, hardware settings
├── users/                   # Per-machine user overrides
│   └── <user>/
│       └── syncthing.nix    # User-specific syncthing folders
└── <feature>.nix            # Machine-specific features
```

## Common Machine Options

The `machine` option set provides common configuration:

```nix
machine = {
  users = [ "lriutzel" ];     # Users to create
  sizeTarget = 2;             # 1=minimal, 2=normal, 3=full
  tui = true;                 # Enable TUI tools
  minimal = false;            # Minimal system (fewer packages)
  gaming = true;              # Gaming support (Steam, etc.)
  impermanence = true;        # Ephemeral root with /persist
  encryptedRoot = true;       # LUKS encrypted root
  lowLevelXF86keys.enable = true;  # Keyboard special keys
  kexec.enable = true;        # Kexec support
};
```

## Gumdrop Network Options

The `gumdrop` option set configures network integration:

```nix
gumdrop = {
  printerScanner = true;           # Network printer/scanner access
  storageServer.enable = true;     # Mount NAS shares
  storageServer.media = true;      # Mount media share
  storageServer.roms = true;       # Mount ROMs share
  storageServer.backup = true;     # Mount backup share

  vpn.server.enable = true;        # Run as VPN server (marulk only)
  vpn.client.enable = true;        # Connect as VPN client
  vpn.client.ip = "10.100.0.X/24"; # VPN IP address
};
```
