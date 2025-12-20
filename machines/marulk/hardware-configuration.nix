{ flake, pkgs, config, lib, ... }: {
  imports = [
    flake.inputs.nixos-hardware.nixosModules.common-pc-ssd
    flake.inputs.nixos-hardware.nixosModules.common-pc
    flake.inputs.nixos-hardware.nixosModules.common-cpu-amd
    flake.inputs.nixos-hardware.nixosModules.common-gpu-amd
    ../../profiles/lenovo-m715q.nix
    (import ../../profiles/disk-workstation-3.nix {
      inherit flake pkgs config lib;
      device = "/dev/nvme0n1";
      isEncrypted = false;
    })
  ];

  config = {
    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "marulk";
    networking.domain = "home.lucasr.com";
    networking.hostId = "070ac4e0";

  };
}
