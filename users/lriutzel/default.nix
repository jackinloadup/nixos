{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
  inherit (lib) mkOption mkIf mkDefault mkOverride optionals elem getExe;
  inherit (lib.types) listOf enum;

  cfg = config.machine;
  ifTui = cfg.sizeTarget > 0;
  ifGraphical = cfg.sizeTarget > 1;
  ifFull = cfg.sizeTarget > 2;
  fullSystems = ["reg" "riko" "zen" "kanye"];
  hostname = config.networking.hostName;
  isFullSystem = elem hostname fullSystems;
  userEnabled = elem username config.machine.users;

  email = "lriutzel@gmail.com";
  username = "lriutzel";
in {


  # Make user available in user list
  options.machine.users = mkOption {
    type = listOf (enum [username]);
  };

  config = {

  };
}
