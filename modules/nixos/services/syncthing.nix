{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf attrNames any;
  normalUsers = attrNames config.home-manager.users;
  userHasService = users: service: any (user: config.home-manager.users.${user}.services.${service}.enable) users;
in
{
  imports = [ ];

  config =
    #{}
    {
      #// mkIf (userHasService normalUsers "syncthing") {
      networking.extraHosts = ''
        127.0.0.3 syncthing.internal
      '';

      networking.firewall.allowedTCPPorts = [ 22000 ];
      networking.firewall.allowedUDPPorts = [ 21027 ];

      # Jan 01 15:57:57 reg network-addresses-lo-start[1763]: adding address 127.0.0.3/8... 'ip addr add 127.0.0.3/8 dev lo' failed: Error: ipv4: Address already assigned.

      #networking.interfaces.lo.ipv4.addresses = [{
      #  address = "127.0.0.3";
      #  prefixLength = 8;
      #}];
    };
  #// mkIf config.services.syncthing.enable {
  #  networking.extraHosts = ''
  #    127.0.0.3 syncthing.internal
  #  '';

  #  services.syncthing = {
  #    extraOptions = {
  #      gui = {
  #        theme = "black";
  #      };
  #    };
  #    guiAddress = "127.0.0.3:80";
  #    openDefaultPorts = true; # TCP/UDP 22000 for transfers and UDP 21027 for discovery
  #    #guiAddress = mkIf cfg.server "syncthing.${domain}";¶
  #    # if syncthing runs as a user
  #    #user = username
  #    #configDir = "/home/${username}/.config/syncthing";
  #    #dataDir = "/home/${username}/.local/share/syncthing";
  #  };
  #};
}
