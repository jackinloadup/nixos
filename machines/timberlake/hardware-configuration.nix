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
  };
}
