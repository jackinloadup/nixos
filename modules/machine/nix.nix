{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf;
  inherit (builtins) hasAttr;

  sizeTarget = if (hasAttr "machine" config)
    then config.machine.sizeTarget
    else 0;
  ifTui = sizeTarget > 0;
in {
  config = {
    nix.settings = {
      trusted-users = [ "root" ];
      auto-optimise-store = ifTui;
      substituters = [ "https://aseipp-nix-cache.global.ssl.fastly.net" ];
    };

    # Enable extra-builtins-file option for nix
    #plugin-files = ${pkgs.nix-plugins.override { nix = config.nix.package; }}/lib/nix/plugins/libnix-extra-builtins.so
    nix.gc = {
      automatic = ifTui;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    nix.nixPath = let path = toString ../../.; in [
      "repl=${path}/repl.nix"
    ];

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

      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };
}
