{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault optionals;
  inherit (builtins) elem hasAttr;

  sizeTarget =
    if (hasAttr "machine" config)
    then config.machine.sizeTarget
    else 0;

  ifTui = sizeTarget > 0;

  builders = [ "reg" "zen" ];
  hostname = config.networking.hostName;
  isBuilder = elem hostname builders;

  MBtoBytes = mb: mb * 1024 * 1024;
  minimumFreeSpace = MBtoBytes 100; # 100MB
  maximumFreeSpace = MBtoBytes 1024; # 1GB

  repoRoot = toString ../../../.;
in {
  config = {
    # Allow unfree packages.
    nixpkgs.config.allowUnfree = true;

    nixpkgs.overlays = [
      flake.inputs.nur.overlays.default
      flake.inputs.self.overlays.default
      flake.inputs.self.overlays.kodi-wayland
    ];

    # disable nix-channel cmd and it's state files
    nix.channel.enable = false;

    nix.settings = {
      download-buffer-size = 524288000; # 500Mb
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "reg.home.lucasr.com-1:8L950S9ptxIIUxhA541X119u8yUxu1PFCchAHHDJ3rY="
      ];
      allowed-users = [ "root" "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = mkDefault ifTui;
      builders-use-substitutes = true;
      substituters = [
        "https://aseipp-nix-cache.global.ssl.fastly.net"
        "https://hyprland.cachix.org"
      ];
    };

    # Enable extra-builtins-file option for nix
    #plugin-files = ${pkgs.nix-plugins.override { nix = config.nix.package; }}/lib/nix/plugins/libnix-extra-builtins.so


    #nix.package = pkgs.nixVersions.nix_2_20;
    nix.package = pkgs.nixVersions.latest;

    nix.gc = {
      automatic = ifTui;
      dates = "weekly";
      options = "--delete-older-than 90d";
    };

    # It seems like nixPath doesn't need to expose this if system is non
    # interactive. This seems to duplicate or extend nix.registry
    nix.nixPath = [
      "nixpkgs=/run/current-system/nixpkgs"
      "flake=/run/current-system/flake"
      "repl=/run/current-system/flake/repl.nix"
    ];

    # This adds symlinks to /run/current-system
    # Also pulls in the flake repo onto the device
    # removed the following line to see if that would change build times
    # ln -sv ${repoRoot} $out/nixos-config
    system.extraSystemBuilderCmds = ''
      ln -sv ${repoRoot} $out/flake
      ln -sv ${pkgs.path} $out/nixpkgs
    '';

    # TODO explore disabling global registry items from  `nix registry list`

    # Flake registries are a convenience feature that allows you to refer to
    # flakes using symbolic identifiers such as nixpkgs for example:
    #   `nix shell nixpkgs#hello-world`
    nix.registry.nixpkgs.flake = flake.inputs.nixpkgs;
    nix.registry.nixpkgs-unstable.flake = flake.inputs.nixpkgs-unstable;
      # nix.registry =
      #   lib.mapAttrs (id: flake: {
      #     inherit flake;
      #     from = {
      #       inherit id;
      #       type = "indirect";
      #     };
      #   })
      #   ({nixpkgs = flake.inputs.nixpkgs;}
      #     // {nixpkgs-unstable = flake.inputs.nixpkgs-unstable;} ); # alias for convenience
      # #(flake.inputs # Expose all flakes
      # #    // {pkgs = flake.inputs.nixpkgs;}); # alias for convenience

    # enable flakes
    # set the min free disk space.
    # If the mount the store is attached to is lower than min-free
    # then nix will gc store items until storage is at max-free
    # I believe this is best effort.
    # Current settings are if less than 100Mb of space left then gc
    # up to 1Gb
    nix.extraOptions = ''
      experimental-features = nix-command flakes

      min-free = ${toString minimumFreeSpace}
      max-free = ${toString maximumFreeSpace}
    '';

    # Example to pass access tokens to nix. Like github or other forge keys
    #nix = {
    #  extraOptions = ''
    #    extra-access-tokens = github.com=github_pat_XYZ
    #  OR include a file with it inside
    #    !include ${config.sops.secrets.nixAccessTokens.path}
    #  '';
    #};

    #sops.secrets.nixAccessTokens = {
    #  mode = "0440";
    #  group = config.users.groups.keys.name;
    #};

    #nix.distributedBuilds = (!isBuilder);
    nix.distributedBuilds = true;

    nix.buildMachines = []
      ++ optionals (hostname != "reg") [{
        hostName = "reg.home.lucasr.com";
        sshUser = "lriutzel";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 16;
        speedFactor = 3;
        supportedFeatures = [
          "big-parallel"
          "nixos-test"
          "kvm"
        ];
      }]
      ++ optionals (hostname != "zen") [{
        hostName = "zen.home.lucasr.com";
        sshUser = "lriutzel";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 16;
        speedFactor = 3;
        supportedFeatures = [
          "big-parallel"
          "nixos-test"
          "kvm"
        ];
      }];

    nix.sshServe = mkIf isBuilder {
      enable = true;
      protocol = "ssh-ng";
      write = false; # maybe in the future?
      # keys = []; # in secrets
    };

  };
}
