{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf config.programs.taskwarrior.enable {
    # this is for nixos not home-manager needs to figure that one out
    #environment.shellAliases = {
    #  "tt" = "taskwarrior-tui";
    #};

    home.packages = [
      pkgs.taskwarrior-tui
    ];

    programs.taskwarrior = {
      colorTheme = "dark-blue-256";
      config = {
        confirmation = false;
        report.minimal.filter = "status:pending";
        report.active.columns = ["id" "start" "entry.age" "priority" "project" "due" "description"];
        report.active.labels = ["ID" "Started" "Age" "Priority" "Project" "Due" "Description"];
      };
    };
  };
}
