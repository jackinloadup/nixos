# Documentation
Personal home lab nixos setup exposed as a flake.

## Nixos Links
 - Local Manual `man configuration.nix`
 - [Remote Manual](https://nixos.org/manual/nixos/stable/)
 - [Wiki](https://wiki.nixos.org/wiki/NixOS_Wiki)
 - [Package Search](https://search.nixos.org/packages?channel=22.11&from=0&size=50&sort=relevance&type=packages&query=)
 - [Options Search](https://search.nixos.org/packages?channel=22.11&from=0&size=50&sort=relevance&type=packages&query=)
 - [nixos/nixpkgs repo](https://github.com/NixOS/nixpkgs/)


## Home-Manager
 - Local Manual `man home-configuration.nix`
 - [Remote](https://nix-community.github.io/home-manager/options.html)
 - [Repo](https://github.com/nix-community/home-manager)


## Other nix projects in use
 - [impermanence](https://github.com/nix-community/impermanence/)
 - [disko](https://github.com/nix-community/disko)
 - [nixos-hardware](https://github.com/NixOS/nixos-hardware)
 - [nixos-facter](https://github.com/nix-community/nixos-facter)
 - [stylix](https://github.com/nix-community/stylix)
 - [nix-ld](https://github.com/nix-community/nix-ld)
 - [nixvim](https://github.com/nix-community/nixvim)
 - [ucodenix](https://github.com/e-tho/ucodenix/)
 - [nix-flatpak](https://github.com/e-tho/ucodenix/)

## Services
 - [Home Assistant](https://www.home-assistant.io/) - Home automation
 - [Murmur](https://mumble.info/) - Mumble audio chat
 - [Frigate](https://github.com/blakeblackshear/frigate) - Camera NVR
 - [Adguard Home](https://adguard.com) - Network adblock
 - [immich](https://immich.app/) - Family images
 - [wireguard](https://www.wireguard.com/) - Family VPN
 - [syncthing](https://syncthing.net/) - File sync for backup
 - [paperless-ngx](https://docs.paperless-ngx.com/) - Document manager my printer is connected to
 - [go2rtc](https://github.com/AlexxIT/go2rtc) - Camera Streaming
 - [smokeping](https://oss.oetiker.ch/smokeping/) - service monitor
 - [nextcloud](https://nextcloud.com/) - Documents
 - [collabora](https://www.collabora.com/) - multi user document editing

# Install 2.0
- (new machine) boot nixos iso via PXE or usb
- (new machine) set password for nixos user `passwd`
- (new machine) get ip `ip addr`
- (new machine) check disk `lsblk`
- (new machine) install keys `curl "https://github.com/jackinloadup.keys" > ~/.ssh/authorized_keys`
- (new machine) get factor.json `sudo nix run --option experimental-features "nix-command flakes" nixpkgs#nixos-facter -- -o facter.json`
- (existing machine) add disk encryption key into /tmp/disk.key
- (existing machine) nix run github:nix-community/nixos-anywhere -- --build-on local --flake ~/Projects/nixos-config/master#lyza -i ~/.ssh/id_rsa --disk-encryption-keys /tmp/disk.key /tmp/disk.key nixos@10.16.1.159

## test with vm. Must comment out or disable all encryption due to vm-test not supporting disk key transfer
- (existing machine) nix run github:nix-community/nixos-anywhere -- --flake ~/Projects/nixos-config/master#lyza -i ~/.ssh/id_rsa --vm-test



If mounts didn't come up immediately, re apply tmpfiles
`sudo systemctl restart systemd-tmpfiles-resetup.service`

## Install 1.0
 - boot nixos-install iso
 - format disk using [disko](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
   - Prepare disk layout config
      - Copy layout over: `scp ./profile/disks/disko-laptop-1.nix#TBD <target>:/tmp/disko-config.nix`
      - Find disk name: `sudo fdisk -l`
      - Place disk in device variable `vim /tmp/disk-config.nix`
   - Create temp file with the password which will be applied to the disk
      - `vim /tmp/disk.key`
   - Perform the format
      - `sudo nix run github:nix-community/disko -- --mode disko /tmp/disko-config.nix`
   - Follow [Complete the NixOS
     installation](https://github.com/nix-community/disko/blob/master/docs/quickstart.md#step-7-complete-the-nixos-installation)
   - Before running `nixos-install`
      - Set
        [networking.hostId](https://search.nixos.org/options?channel=23.05&show=networking.hostId&from=0&size=50&sort=relevance&type=packages&query=networking.hostId)
      - Add the following config to enable ssh ```
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
      ```

- reboot
- Apply machine config from local donor build machine
  - `NIX_SSHOPTS="-t" nixos-rebuild boot --flake ~/Projects/nixos-config/master#zen --target-host root@zen`

