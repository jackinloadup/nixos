{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption genAttrs attrNames;
  cfg = config.machine;
  ifTui = config.machine.sizeTarget > 0;
  ifGraphical = config.machine.sizeTarget > 1;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  imports = [ ];

  options.machine.docker = mkEnableOption "Enable docker";

  config = mkIf cfg.docker {
    networking.hosts = {
      "172.17.0.1" = [ "host.docker.internal" ];
    };
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    environment.systemPackages = with pkgs; mkIf ifTui [ # if system is not minimal
      dive
    ] // mkIf ifGraphical [ # if system is full user
    ];

    users.users = addExtraGroups normalUsers [ "docker" ];

    #systemd.services."docker-network-paperless" = {
    #  serviceConfig.Type = "oneshot";
    #  wantedBy = [ "docker-paperless-app.service" ];
    #  script = ''
    #    ${pkgs.docker}/bin/docker network inspect paperless > /dev/null 2>&1 || ${pkgs.docker}/bin/docker network create paperless
    #  '';
    #};
  };
}
