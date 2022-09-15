{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  imports = [ ];

  options.machine.chirp = mkEnableOption "Enable chirp";

  config = mkIf config.machine.chirp {
    environment.systemPackages = with pkgs; [ chirp ];

    users.users.lriutzel.extraGroups = [ "dialout" ];
  };
}
