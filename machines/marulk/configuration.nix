{
  self,
  flake,
  pkgs,
  lib,
  ...
}:
# Machine runs DNS and home-assistant vm
let
  inherit (lib) mkForce mkDefault;
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
    #./nebula-lighthouse.nix
    ./adguard.nix
  ];

  config = {

    boot.initrd.verbose = true;

    machine = {
      users = [ "lriutzel" ];
      sizeTarget = 1;
      home-assistant = true;
      tui = true;
    };

    gumdrop.vpn.server.enable = true;

    #nix.settings.max-jobs = mkDefault 8;

    nixpkgs.overlays = [
      flake.inputs.self.overlays.default
    ];

    networking.hostName = "marulk";
    networking.networkmanager.enable = mkForce false;
    networking.bridges.br0.interfaces = ["enp1s0f0"];
    networking.interfaces.br0.useDHCP = true;

    networking.dhcpcd = {
      #wait = "ipv4";
      persistent = true;
    };

    #networking.nat = {
    #  enable = true;
    #  externalInterface = "enp1s0";
    #  internalInterfaces = ["virbr0"];
    #  internalIPs = [
    #    "192.168.122.0/24"
    #  ];
    #  forwardPorts = [
    #    {
    #      destination = "192.168.122.182:1883";
    #      proto = "tcp";
    #      sourcePort = 1883;
    #    }
    #    {
    #      destination = "192.168.122.182:8123";
    #      proto = "tcp";
    #      sourcePort = 8123;
    #    }
    #  ];
    #};
    services.jellyfin = {
      enable = true;
      openFirewall = false; # handle http via nginx
    };
    # tcp is handled via nginx
    networking.firewall.allowedUDPPorts = [
      1900
      7359
    ];
    services.nginx.virtualHosts."jellyfin.home.lucasr.com".locations."/" = {
      proxyPass = "http://localhost:8096/";
      proxyWebsockets = true;
    };

    services.nextcloud.enable = true;

    # wireguard-tools
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    #networking.bridges.br0.interfaces = ["enp1s0f0"];
    #services.wg-access-server = {
    #  enable = true;
    #  settings = {
    #    loglevel = "info";
    #    storage = "sqlite3:///var/lib/wg-access-server/db.sqlite3";
    #    externalHost = "home.lucasr.com";
    #    dns = {
    # enabled = true;
    #      upstream = [
    #        "10.16.0.2"
    #      ];
    #    };
    #    vpn = {
    #      gatewayInterface = "br0";
    #      cidr = "10.44.0.0/24";
    #      cidrv6 = "0"; # disable
    #      clientIsolation = false;
    #      allowedIPs = [
    #        "0.0.0.0/0"
    #        #"10.16.1.0/24"
    #      ];
    #    };
    #  };
    #};

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.05"; # Did you read the comment?
  };
}
