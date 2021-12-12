{ lib, pkgs, config, ... }:
with lib;
{
  imports = [ ];

  options.machine.adb = mkEnableOption "Enable ADB";

  config = mkIf config.machine.adb {
    programs.adb.enable = true;

    users.users.lriutzel.extraGroups = ["adbusers"];
  };
}
