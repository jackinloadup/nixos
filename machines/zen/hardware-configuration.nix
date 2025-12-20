{pkgs, flake, config, ...}: {
  imports = [
    flake.inputs.nixos-hardware.nixosModules.common-pc-ssd
    flake.inputs.nixos-hardware.nixosModules.common-pc
    flake.inputs.nixos-hardware.nixosModules.common-cpu-amd
    flake.inputs.nixos-hardware.nixosModules.common-gpu-amd
    ../../profiles/disk-workstation-2.nix
    ../../profiles/amd.nix
    ../../profiles/pro-art-7800x3d.nix
    #flake.inputs.chaotic.nixosModules.default
  ];

  config = {
    # We have a lot of ram. We can wait a bit before we think we need to swap.
    # does this even matter if I don't have swap attached?
    boot.kernel.sysctl."vm.swappiness" = 5;

    # More tmp space is needed to build kernel
    # original 16G (50%), known needed 20G, new 24G
    boot.tmp.tmpfsSize = "75%";

    programs.fuse.userAllowOther = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "zen";
    networking.domain = "home.lucasr.com";
    networking.hostId = "c99cd5f7";
  };
}
