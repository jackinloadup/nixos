{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (builtins) hasAttr;

  sizeTarget =
    if (hasAttr "machine" config)
    then config.machine.sizeTarget
    else 0;

  ifTui = sizeTarget > 0;
  isReg = config.networking.hostName == "reg";

  MBtoBytes = mb: mb * 1024 * 1024;
  minimumFreeSpace = MBtoBytes 100; # 100MB
  maximumFreeSpace = MBtoBytes 1024; # 1GB

  repoRoot = toString ../../../.;
in {
  config = {
    nix.settings = {
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "reg.home.lucasr.com-1:8L950S9ptxIIUxhA541X119u8yUxu1PFCchAHHDJ3rY="
      ];
      trusted-users = ["root"];
      auto-optimise-store = mkDefault ifTui;
      substituters = [ "https://aseipp-nix-cache.global.ssl.fastly.net" ];
    };

    # Enable extra-builtins-file option for nix
    #plugin-files = ${pkgs.nix-plugins.override { nix = config.nix.package; }}/lib/nix/plugins/libnix-extra-builtins.so
    nix.gc = {
      automatic = ifTui;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # It seems like nixPath doesn't need to expose this if system is non
    # interactive. This seems to duplicate or extend nix.registry
    nix.nixPath = [
      "nixpkgs=/run/current-system/nixpkgs"
      "nixos-config=/run/current-system/nixos-config"
      "repl=/run/current-system/nixos-config/repl.nix"
    ];

    # This adds symlinks to /run/current-system
    system.extraSystemBuilderCmds = ''
      ln -sv ${pkgs.path} $out/nixpkgs
      ln -sv ${repoRoot} $out/nixos-config
    '';

    # Flake registries are a convenience feature that allows you to refer to
    # flakes using symbolic identifiers such as nixpkgs for example:
    #   `nix shell nixpkgs#hello-world`
    nix.registry =
      lib.mapAttrs (id: flake: {
        inherit flake;
        from = {
          inherit id;
          type = "indirect";
        };
      })
      (inputs # Expose all flakes
        // {pkgs = inputs.nixpkgs;}); # alias for convenience

    # enable flakes
    # set the min free disk space.
    # If the mount the store is attached to is lower than min-free
    # then nix will gc store items until storage is at max-free
    # I believe this is best effort.
    # Current settings are if less than 100Mb of space left then gc
    # up to 1Gb
    nix.extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true

      min-free = ${toString minimumFreeSpace}
      max-free = ${toString maximumFreeSpace}
      builders-use-substitutes = true
    '';

    nix.distributedBuilds = (!isReg);

    nix.buildMachines = mkIf (!isReg) [
      {
        hostName = "reg";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 16;
        speedFactor = 3;
        supportedFeatures = [
          "big-parallel"
          "nixos-test"
          "kvm"
        ];
      }
    ];

  };
}
