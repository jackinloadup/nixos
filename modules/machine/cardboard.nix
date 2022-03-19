{ lib, pkgs, config, ... }:

with lib;
{
  imports = [ ];

  options.machine.windowManagers = mkOption {
    type = with types; nullOr (listOf (enum [ "cardboard" ]));
  };

  config = mkIf (builtins.elem "cardboard" config.machine.windowManagers) {
    environment.systemPackages = with pkgs; [
      cardboard
    ];
  };
}

