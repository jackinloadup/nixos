{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.machine;
in {
  config = {
    nix.package = pkgs.nix_2_4; # support flakes
    nix.trustedUsers = [ "root" ];
    nix.autoOptimiseStore = mkIf (cfg.sizeTarget > 0) true;
    # Enable extra-builtins-file option for nix
    #plugin-files = ${pkgs.nix-plugins.override { nix = config.nix.package; }}/lib/nix/plugins/libnix-extra-builtins.so
    nix.gc = {
      automatic = mkIf (cfg.sizeTarget > 0) true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

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
