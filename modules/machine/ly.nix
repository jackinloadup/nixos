{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption types;
in {
  imports = [];

  options.machine.displayManager = mkOption {
    type = with types; nullOr (enum ["ly"]);
  };

  config = mkIf (config.machine.displayManager == "ly") {
    environment.systemPackages = with pkgs; [
      ly
    ];
  };
}
