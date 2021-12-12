{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  imports = [ ];

  options.machine.docker = mkEnableOption "Enable docker";

  config = mkIf config.machine.docker {
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    # might only apply to libvirt
    environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 0) [ # if system is not minimal
      dive
    ] // mkIf (cfg.sizeTarget > 1) [ # if system is full user
    ];

    users.users.lriutzel.extraGroups = [ "docker" ];

    #systemd.services."docker-network-paperless" = {
    #  serviceConfig.Type = "oneshot";
    #  wantedBy = [ "docker-paperless-app.service" ];
    #  script = ''
    #    ${pkgs.docker}/bin/docker network inspect paperless > /dev/null 2>&1 || ${pkgs.docker}/bin/docker network create paperless
    #  '';
    #};
  };
}
