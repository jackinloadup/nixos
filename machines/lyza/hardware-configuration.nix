{flake, pkgs, config, lib, ...}: {
  imports = [
    ../../profiles/lenovo-m715q.nix
    (import ../../profiles/disk-workstation-3.nix {
      inherit flake pkgs config lib;
      device = "/dev/nvme0n1";
      isEncrypted = false;
    })
  ];

  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "lyza";
    networking.domain = "studio.lucasr.com";
    networking.hostId = "1a81f97a";
  };
}
