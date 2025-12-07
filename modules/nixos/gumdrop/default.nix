{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) attrNames mkIf;
  inherit (builtins) filter readFile elem pathExists hasAttr;
  selfLib = import ../../../lib/secrets.nix {};
  inherit (selfLib) machines hostExists hostHasService
                    smachine shostExists shostHasService;


  hostname = config.networking.hostName;
  settings = import ../../../settings;
  normalUsers = if (hasAttr "home-manager" config)
    then attrNames config.home-manager.users
    else [];

  machinesWithHostKeys = filter (host: hostHasService host "sshd") machines;
  machineKeys = map (host: readFile ../../../machines/${host}/sshd/public_key) machinesWithHostKeys;

  lriutzelKeys = [
    # password protected private key file
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1pkTHUApo4oX3PLXnXcTLZ7xszEdeYJfBFEUyliYgD32INvsvQhl3ZmhZ1P5IMDmrMb/zd9dsMbtfY1fgy+unSMblb6RS7SxOt6vfifxNc1R7ylaa1HufgAhJHT+bSWNGPliA5Ds2XbdbPh3I6yRFT+V37QUz9EesDFaUC0JVEgqVOAUikSAGXhAeskTpQhD//32lEPwPM45iVS7Zix34LYrQ/RyVL9EKMRGLGFkJ3UgLsn6j8Wos7EM9YoW8s7lueShBcCFLqGus2Mjg71L14MWM1CCtaiFeBr04BtmhtvCjKJ505zfVLWLC8bg/URR6mIZABc1OqKRnm017tlJ3Q== lriutzel@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO/wQSQHq1Wmzbwg8uJM4vK/exUWmsT49kmkPdtJU0v lriutzel@gmail.com"

    # pin protected solo2 security key
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPxPFMNGK0tw467usZYAA1mjgB2owDFBQT939dzOlBWyAAAABHNzaDo= orange"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINmfKdhabJag/k0w78kqBG1PL8w+WMv7xWp4VbkdhtINAAAABHNzaDo= black"
  ];

in {
  imports = [
    ./frigate.nix
    ./printer-scanner.nix
    ./pihole.nix
    ./scanned-document-handling.nix
    ./storage-server.nix
    ./vpn.nix
  ];

  config = {
    boot.initrd.network.ssh.authorizedKeys = lriutzelKeys;
    boot.initrd.network.ssh.hostKeys = [ "/etc/ssh/initrd_ssh_host_ed25519_key" ];
    boot.initrd.secrets = mkIf (hostHasService hostname "tor-boot-service" && config.boot.initrd.network.tor.enable) {
      "/etc/tor/onion/bootup/hostname" = config.age.secrets."tor-service-${hostname}-hostname".path;
      "/etc/tor/onion/bootup/hs_ed25519_public_key" = config.age.secrets."tor-service-${hostname}-hs_ed25519_public_key".path;
      "/etc/tor/onion/bootup/hs_ed25519_secret_key" = config.age.secrets."tor-service-${hostname}-hs_ed25519_secret_key".path;
    };
    environment.etc."ssh/initrd_ssh_host_ed25519_key" = mkIf (shostHasService hostname "init-sshd") {
      source = config.age.secrets."init-sshd-${hostname}-private-key".path;
      mode = "0400";
    };

    environment.etc."ssh/initrd_ssh_host_ed25519_key.pub" = mkIf (hostHasService hostname "init-sshd") {
      source = ../../../machines/${hostname}/init-sshd/public_key;
      mode = "0400";
    };

    environment.etc."ssh/ssh_host_ed25519_key" = mkIf (shostHasService hostname "sshd") {
      source = config.age.secrets."sshd-${hostname}-private-key".path;
      mode = "0400";
    };
    environment.etc."ssh/ssh_host_ed25519_key.pub" = mkIf (hostHasService hostname "sshd") {
      source = ../../../machines/${hostname}/sshd/public_key;
      mode = "0400";
    };

    # may not be nessisary if multiple dhcp search/domain things stack
    # as the machine is connected to more networks
    networking.search = ["home.lucasr.com"];
    networking.domain = "home.lucasr.com";

    networking.wireless.secretsFile = config.age.secrets.system-wireless-networking.path;
    networking.wireless.networks = {
      "epic" = { pskraw = "ext:psk_gumdrop"; };
      "Arpanet" = { pskRaw = "ext:psk_gumdrop"; };
      "Serious-panda-town" = { pskRaw = "ext:psk_nathan_ruby"; };
    };

    # "wg0" is the network interface name. You can name the interface arbitrarily.
    networking.wireguard.interfaces.wg0 = mkIf (shostHasService hostname "wg-vpn") {
    #networking.wg-quick.interfaces.wg0 = mkIf (shostHasService hostname "wg-vpn") {
        privateKeyFile = config.age.secrets."wg-vpn-${hostname}".path;
    };

    nix.sshServe.keys = machineKeys;

    # Github known host keys can be gathered automatically via:
    # https://docs.github.com/en/rest/meta?apiVersion=2022-11-28#get-github-meta-information
    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints

    # we could have new hosts added automatically if the dir was scanned
    # TODO add tor hosts
    programs.ssh.knownHosts = let
      addNixosHost = (name: {
        extraHostNames = [ "${name}.home.lucasr.com" ];
        publicKeyFile = ../../../machines/${name}/sshd/public_key;
      });
    in {
      reg = addNixosHost "reg";
      riko = addNixosHost "riko";
      lyza = addNixosHost "lyza";
      marulk = addNixosHost "marulk";
      nat = addNixosHost "nat";
      zen = addNixosHost "zen";
      timberlake = addNixosHost "timberlake";
      "truenas" = {
        extraHostNames = [ "truenas.home.lucasr.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgiC6kYG2AKcv1Uv9sb3tDxcFL+QFt23HcHVJOKn1pi";
      };
      "mikrotik" = {
        extraHostNames = [ "mikrotik.home.lucasr.com" "10.16.1.1" ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABAwAAAQEA7LFCcWkaZimEONjBTPXAHO3PQpa9xtSWof2uyzNyIPWQm8hWuLKb3zIm82zRiLz/Hw5da6QHG7EXxI0RANYQ+uHHypYUWHw8z/JJ0XLwUYJHvOHc9I14wq5p9BxSg3NXP1dKDl5buygbQxMfbpA9J6qlTTVgq4grSH3G6KvfcC2s1mEjnKYzaEhp7r1/MQ/WaRF5PoZBOXCvnkRFeQXjKryj2vZ/92sB/eliYfyQ3SwKJe+NwSK6pGrgyqfnUoXbNcxSgOWChI2ejs5mm5svpv+Kznc13YOGRNxmdvWmusxP6CHxBBYdvGEngGy0EFc4a2GHx7neQRy4sdqRmDewyw==";
      };
      "seedbox" = {
        extraHostNames = [ "seed.tac0bell.com" "seed.lucasr.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQq/HzkzQYDxbfKByoul/hQtrvIcCS7Xrwh+n2Om83C";
      };
    };

    security.acme.acceptTerms = true;
    security.acme.defaults = {
      email = "lriutzel@gmail.com";
      dnsProvider = "namecheap";
      credentialFiles = {
        "NAMECHEAP_API_USER_FILE" = config.age.secrets.namecheap-api-user.path;
        "NAMECHEAP_API_KEY_FILE" = config.age.secrets.namecheap-api-key.path;
      };
    };
    security.acme.certs."lucasr.com" = mkIf (hostname == "marulk") {
      domain = "*.lucasr.com";
    };

    services.syncthing.settings.devices = {
      truenas = {
        name = "TrueNAS";
        id = "NRRICJD-QXJLVHR-AHNX2Y5-GL2BOQV-XV3GFHP-NLRPJ5P-TWSCK4I-LAXTRAE";
        addressess = [
          "tcp4://freenas.home.lucasr.com"
          "tcp4://10.16.1.56"
          "dynamic"
        ];
      };
    };

    # set logitec mouse to autosuspend after 60 seconds
    services.udev.extraRules = ''
      # Logitech Unifying Receiver
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="60000"
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52f", TEST=="power/control", ATTR{power/control}="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="120000"

      # Lofree mouse - Maxxter Wireless-Receiver
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="248a", ATTR{idProduct}=="5b2f", TEST=="power/control", ATTR{power/control}="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="120000"
    '';

    services.paperless.passwordFile = config.age.secrets.commonPass.path;

    services.nextcloud.config.adminpassFile = config.age.secrets.commonPass.path;
    services.nextcloud.config.dbpassFile = config.age.secrets.nextcloud-db-pass.path;
    services.pgadmin.initialEmail = "lriutzel@gmail.com";
    services.pgadmin.initialPasswordFile = config.age.secrets.commonPass.path;

    #services.immich.secretsFile = "/run/secrets/immich";
    services.immich.secretsFile = config.age.secrets.immich.path;


    users.users = {
      root = {
        hashedPasswordFile = config.age.secrets.lriutzel-hashed-password.path;
        openssh.authorizedKeys.keys = lriutzelKeys;
      };

      # install user - NEED another way to detect if on install-iso
      nixos = mkIf ((hasAttr "disko" config) && (! config.disko.enableConfig)) {
        hashedPasswordFile = config.age.secrets.lriutzel-hashed-password.path;
        openssh.authorizedKeys.keys = lriutzelKeys;
      };

      lriutzel = mkIf (elem "lriutzel" normalUsers) {
        hashedPasswordFile = config.age.secrets.lriutzel-hashed-password.path;
        openssh.authorizedKeys.keys = lriutzelKeys;
      };

      criutzel = mkIf (elem "criutzel" normalUsers) {
        hashedPasswordFile = config.age.secrets.criutzel-hashed-password.path;
        openssh.authorizedKeys.keys = lriutzelKeys;
      };

      briutzel = mkIf (elem "briutzel" normalUsers) {
        hashedPasswordFile = config.age.secrets.briutzel-hashed-password.path;
        openssh.authorizedKeys.keys = lriutzelKeys;
      };

      serviceftp = mkIf config.gumdrop.scanned-document-handling.enable {
        #hashedPassword = config.age.secrets.lriutzel-hashed-password;
        password = "calmfarm54";
      };
    };

    #networking.wg-quick.interfaces = {}
    #  // optionalAttrs cfg.server.enable {
    #    # "wg0" is the network interface name. You can name the interface arbitrarily.
    #    wg0 = {
    #      # Determines the IP address and subnet of the server's end of the tunnel interface.
    #      address = [ "10.100.0.1/24" ];

    #      # The port that WireGuard listens to. Must be accessible by the client.
    #      listenPort = 51820;

    #      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
    #      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
    #      postUp = ''
    #        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
    #      '';

    #      # This undoes the above command
    #      postDown = ''
    #        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
    #      '';

    #      peers = [
    #        {
    #          #name = "lucas-phone";
    #          publicKey = "4bJ3FxfAWkfr8dbNWLHdh7fIcavtt/EbTKo/1q4C5Fs=";
    #          allowedIPs = [ "10.100.0.2/32" ];
    #        }
    #        {
    #          #name = "riko";
    #          publicKey = "hMalIs+gw/ooiFVjHBzysS6Wn1ZTC9AOKnSCyOEvVQc=";
    #          allowedIPs = [ "10.100.0.3/32" ];
    #        }
    #        {
    #          #name = "lyza";
    #          publicKey = "439vHIw45W3VpVm1OllB6QN85VSUnIKT3RGWzRuzLSE=";
    #          allowedIPs = [ "10.100.0.4/32" ];
    #          persistentKeepalive = 25;
    #        }
    #        {
    #          #name = "kanye";
    #          publicKey = "85q15pyFUBdt1UTE5BLklvy9uKknXdWVQWTge1Vy1nk=";
    #          allowedIPs = [ "10.100.0.5/32" ];
    #        }
    #        {
    #          #name = "zen";
    #          publicKey = "5zadvDWL6pMIlqYI7dVrrAXFxVqHDRvJo6u+LQ0WpSQ=";
    #          allowedIPs = [ "10.100.0.6/32" ];
    #        }
    #        {
    #          #name = "christine-phone";
    #          publicKey = "TkkSJLCOTB6/qoWh5hZzyZEtyswsRftFLjcTvKo1RBc=";
    #          allowedIPs = [ "10.100.0.7/32" ];
    #        }
    #        {
    #          #name = "timberlake";
    #          publicKey = "TSIU47c//x361/fxl1fxZ3cpSWbH7G06jt/FVqfYpRM=";
    #          allowedIPs = [ "10.100.0.8/32" ];
    #        }
    #        {
    #          #name = "nat";
    #          publicKey = "LFhXpxrDepNzAqVwcbvEpqDKlIUDaHyIG4t9mIsz6mk=";
    #          allowedIPs = [ "10.100.0.9/32" ];
    #        }
    #        {
    #          #name = "christine-ipad";
    #          publicKey = "RHhV4nC7YrM/iTJmUda56JumWCiyVfkQ2Yc17qJI6ws=";
    #          allowedIPs = [ "10.100.0.10/32" ];
    #        }
    #        {
    #          #name = "reg";
    #          publicKey = "ycZ424QpGCSIVswLUk2EweH+Z7sTc33dH0B0AER4pgc=";
    #          allowedIPs = [ "10.100.0.11/32" ];
    #        }
    #      ];

    #    };
    #  }
    #  // optionalAttrs cfg.client.enable {
    #    # "wg0" is the network interface name. You can name the interface arbitrarily.
    #    wg0 = {
    #      # Determines the IP address and subnet of the server's end of the tunnel interface.
    #      address = [ cfg.client.ip ];
    #      dns = [ "10.100.0.1" ];

    #      # The port that WireGuard listens to. Must be accessible by the client.
    #      #listenPort = 51820; # shouldn't be on client
    #      #dynamicEndpointRefreshSeconds = 5; # not in wg-quick
    #      #allowedIPsAsRoutes = false; # not in wg-quick

    #      # Set DNS for wg0 after it comes up
    #      postUp = ''
    #        resolvectl dns wg0 10.100.0.1
    #        resolvectl domain wg0 "home.lucasr.com"
    #      '';

    #      # Remove DNS when wg0 goes down
    #      postDown = ''
    #        resolvectl revert wg0
    #      '';

    #      peers = [
    #        {
    #          #name = "marulk";
    #          endpoint = "vpn.lucasr.com:51820";
    #          publicKey = "KrWVR+VV04OOmt63FOeqx9UKE4en20lDl6pGieLQSj0=";
    #          # traversing to gumdrop breaks when at gumdrop
    #          #allowedIPs = [ "10.100.0.0/24"  "10.16.1.0/24"];
    #          allowedIPs = [ "10.100.0.0/24" ];
    #          persistentKeepalive = 25;
    #        }
    #      ];
    #    };
    #  };

    #systemd.services.wg0_dynamic_endpoint = {
    #  enable = true;
    #  description = "Refresh wg0 WireGuard interface to resolve dynamic endpoints";
    #  serviceConfig = {
    #    Type = "oneshot";
    #    ExecStart = ''
    #      ${pkgs.wireguard-tools}/bin/wg-quick down wg0 || true
    #      ${pkgs.wireguard-tools}/bin/wg-quick up wg0
    #    '';
    #  };
    #};

    #systemd.timers.wg0_dynamic_endpoint = {
    #  description = "Refresh wg0 WireGuard interface to resolve dynamic endpoints";
    #  #Unit = { Description = "Refresh wg0 WireGuard interface to resolve dynamic endpoints"; };
    #  wantedBy = [ "timers.target" "wg-quick-wg0.service" ];
    #  timerConfig = {
    #    OnBootSec = "10s";
    #    OnUnitActiveSec = "30s";
    #    OnUnitInactiveSec = "30s";
    #    Unit = "wg0_dynamic_endpoint.service";
    #    Persistent = true;
    #    #OnUnitActiveSec = "${toString refreshInterval}s";
    #  };
    #};
  };
}
