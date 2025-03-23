# Documentation
Personal home lab nixos setup exposed as a flake.


## Nixos
 - Local Manual `man configuration.nix`
 - [Remote Manual](https://nixos.wiki/wiki/Resources)
 - [Wiki](https://nixos.wiki/)
 - [Package Search](https://search.nixos.org/packages?channel=22.11&from=0&size=50&sort=relevance&type=packages&query=)
 - [Options Search](https://search.nixos.org/packages?channel=22.11&from=0&size=50&sort=relevance&type=packages&query=)


## Home-Manager
 - Local Manual `man home-configuration.nix`
 - Remote

## Install
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
- Apply machine config from local/donar/build machine
  - `NIX_SSHOPTS="-t" nixos-rebuild boot --flake ~/Projects/nixos-config/master#jesus --target-host root@jesus`


# Install 2.0
- (new machine) boot PXE nixos-iso or usb
- (new machine) set password for nixos user `passwd`
- (new machine) get ip `ip addr`
- (new machines) check disk `lsblk`
- (existing machine) add disk encryption key into /tmp/disk.key
- (existing machine) nix run github:nix-community/nixos-anywhere -- --flake ~/Projects/nixos-config/master#lyza -i ~/.ssh/id_rsa --disk-encryption-keys /tmp/disk.key /tmp/disk.key nixos@10.16.1.159

## test with vm. Must comment out or disable all encryption due to vm-test not supporting disk key transfer
- (existing machine) nix run github:nix-community/nixos-anywhere -- --flake ~/Projects/nixos-config/master#lyza -i ~/.ssh/id_rsa --vm-test

