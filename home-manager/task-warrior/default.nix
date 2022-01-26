{ config, pkgs, nixosConfig, lib, inputs, ... }:
{
  imports = [
  ];

  # this is for nixos not home-manager needs to figure that one out
  #environment.shellAliases = {
  #  "tt" = "taskwarrior-tui";
  #};

  home.packages = with pkgs; lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) [
    taskwarrior-tui
  ];

}
