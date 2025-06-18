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
    "ssh-rsa aaaab3nzac1yc2eaaaabiwaaaqea1pkthuapo4ox3plxnxctlz7xszedeyjfbfeuyliygd32invsvqhl3zmhz1p5imdmrmb/zd9dsmbtfy1fgy+unsmblb6rs7sxot6vfifxnc1r7ylaa1hufgahjht+bswngplia5ds2xbdbph3i6yrft+v37quz9eesdfauc0jvegqvoauiksagxhaesktpqhd//32lepwpm45ivs7zix34lyrq/ryvl9ekmrglgfkj3uglsn6j8wos7em9yow8s7lueshbccflqgus2mjg71l14mwm1cctaifebr04btmhtvcjkj505zfvlwlc8bg/urr6mizabc1oqkrnm017tlj3q== lriutzel@gmail.com"
    "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaipo/wqsqhq1wmzbwg8ujm4vk/exuwmst49kmkpdtju0v lriutzel@gmail.com"

    # pin protected solo2 security key
    "sk-ssh-ed25519@openssh.com aaaagnnrlxnzac1lzdi1nte5qg9wzw5zc2guy29taaaaipxpfmngk0tw467uszyaa1mjgb2owdfbqt939dzolbwyaaaabhnzado= orange"
    "sk-ssh-ed25519@openssh.com aaaagnnrlxnzac1lzdi1nte5qg9wzw5zc2guy29taaaainmfkdhabjag/k0w78kqbg1pl8w+wmv7xwp4vbkdhtinaaaabhnzado= black"
  ];

in {
  imports = [
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

    services.paperless.passwordFile = config.age.secrets.badPass.path;

    services.nextcloud.config.adminpassFile = config.age.secrets.badPass.path;
    services.nextcloud.config.dbpassFile = config.age.secrets.nextcloud-db-pass.path;
    services.pgadmin.initialEmail = "lriutzel@gmail.com";
    services.pgadmin.initialPasswordFile = config.age.secrets.badPass.path;

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

  };
}
