{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption types;
in {
  imports = [];

  #config = mkIf (config.machine.displayManager == "ly") {
  #  environment.systemPackages = with pkgs; [
  #    ly
  #  ];
  #};
}
