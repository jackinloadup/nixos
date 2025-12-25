{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf genAttrs attrNames;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (_user: { extraGroups = groups; }));
in
{
  config = mkIf config.virtualisation.docker.enable {
    networking.hosts = {
      "172.17.0.1" = [ "host.docker.internal" ];
    };
    virtualisation.docker = {
      autoPrune.enable = true;
    };

    environment.systemPackages = [
      # if system is not minimal
      pkgs.dive # image inspector
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
