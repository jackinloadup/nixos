{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  imports = [ ];

  options.machine.chirp = mkEnableOption "Enable chirp";

  config = mkIf config.machine.chirp {
    environment.systemPackages = with pkgs; if (cfg.sizeTarget > 0) then [ # if system is not minimal
      chirp
    ] else [];

    users.users.lriutzel.extraGroups = [ "dialout" ];
  };
}
