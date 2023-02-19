{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkOption types;
  inherit (builtins) elem;
in {
  imports = [ ];

  options.machine.windowManagers = mkOption {
    type = with types; nullOr (listOf (enum [ "cardboard" ]));
  };

  config = mkIf (elem "cardboard" config.machine.windowManagers) {
    environment.systemPackages = with pkgs; [
      cardboard
    ];
  };
}

