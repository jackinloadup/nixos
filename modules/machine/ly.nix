{ lib, pkgs, config, ... }:

with lib;
{
  imports = [ ];

  options.machine.displayManager = mkOption {
    type = with types; nullOr (enum [ "ly" ]);
  };

  config = mkIf (config.machine.displayManager == "ly") {
    environment.systemPackages = with pkgs; [
      ly
    ];
  };
}
