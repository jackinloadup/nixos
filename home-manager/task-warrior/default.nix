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

  programs.taskwarrior = {
    enable = true;
    colorTheme = "dark-blue-256";
    config = {
      confirmation = false;
      report.minimal.filter = "status:pending";
      report.active.columns = [ "id" "start" "entry.age" "priority" "project" "due" "description" ];
      report.active.labels = [ "ID" "Started" "Age" "Priority" "Project" "Due" "Description" ];
    };
  };
}
