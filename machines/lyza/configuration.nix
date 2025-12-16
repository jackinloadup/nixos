{ flake, lib, ... }:
# machine runs ?
let
  inherit (lib) mkDefault mkForce;
  isUserFacing = false;
in {

  imports = [
    ./hardware-configuration.nix
    ./home-assistant.nix
    ./frigate.nix
  ];

  config = {
    ##-----------------------------------
    ## initrd remote decrypt root
    ##-----------------------------------
    ## It may be necessary to wait a bit for devices to be initialized.
    ## See https://github.com/NixOS/nixpkgs/issues/98741
    ## Your post-boot network configuration is taken
    ## into account. It should contain:
    #networking.useDHCP = false;
    #networking.interfaces.wlan0.useDHCP = true;
    #networking.interfaces.enp1s0.useDHCP = true;

    boot.initrd = {
      #preFailCommands = lib.mkOrder 400 ''echo "preFailCommands WOOT"'';
      #preLVMCommands = lib.mkOrder 400 "sleep 1";
    #  network.enable = true;
    #  network.ssh.enable = true;
    #  network.tor.enable = true;
    #  network.ntpd.address = "5.78.71.97"; # ip of 0.north-america.pool.ntp.org
    #  systemd.network.enable = true;
    #  systemd.network.wait-online.enable = true;
  #   systemd.network.wait-online.ignoredInterfaces = [ "lo" ];
    #  systemd.extraBin = {
    #    ip = "${pkgs.iproute2}/bin/ip";
    #    #ps = "${pkgs.procps}/bin/ps";
    #  };

      # TODO I haven't figured out get wifi working
      # Network card drivers. Check `lshw` if unsure.
      #kernelModules = [
      #  "ath9k" # wireless (Atheros)
      #  "r8169" # wired (Realtek)
      #  "usbnet" # USB ethernet
      #];
      # Set the shell profile to meet SSH connections with a decryption
      # prompt that writes to /tmp/continue if successful.
      #network.postCommands = let
      #  # I use a LUKS 2 label. Replace this with your disk device's path.
      #  disk = "/dev/disk/by-label/crypt";
      #in ''
      #  echo 'cryptsetup open ${disk} root --type luks && echo > /tmp/continue' >> /root/.profile
      #  echo 'starting sshd...'
      #'';
      # Block the boot process until /tmp/continue is written to
      #postDeviceCommands = lib.mkOrder 400 ''
      #  echo 'waiting for root device to be opened...'
      #  mkfifo /tmp/continue
      #  cat /tmp/continue
      #'';
      systemd.emergencyAccess = true;
    };
    #-----------------------------------
    boot.plymouth.enable = isUserFacing;
    boot.initrd.verbose = !isUserFacing;

    hardware.bluetooth.enable = isUserFacing;

    networking.firewall.allowedTCPPorts = [
      80 443 # nginx
      5000 # un authenticated frigate
    ];

    services.esphome = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
    };


    services.fwupd.enable = mkForce true;

    services.k3s.enable = false;
    services.k3s.role = "server";
    services.k3s.clusterInit = true;


    services.pipewire.enable = isUserFacing;
    #services.tor.enable = mkForce true;
    #services.tor.client.enable = mkForce true;

    services.desktopManager.gnome.enable = isUserFacing;
    services.displayManager.gdm.enable = isUserFacing;

    #security.tpm2.pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    #security.tpm2.tctiEnvironment.enable = true;  # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
    #users.users.lriutzel.extraGroups = [ "tss" ];  # tss group has access to TPM devices

    machine = {
      users = mkDefault [
        "lriutzel"
      ];
      sizeTarget = 1; # was 1
      minimal = true;
      tui = true;
      impermanence = mkDefault true;
      lowLevelXF86keys.enable = isUserFacing;
      kernel = {
        rebootAfterPanic = mkForce 10;
        panicOnOOM = mkForce true;
        #panicOnFailedBoot = mkForce true;
        panicOnHungTask = mkForce true;
        panicOnHungTaskTimeout = mkForce 1;
      };
    };

    gumdrop = {
    #  printerScanner = false;
    #  storageServer.enable = false;
    #  storageServer.media = true;
    #  storageServer.roms = true;

      vpn.server.endpoint = "vpn.lucasr.com:51820";
      vpn.client.enable = true;
      vpn.client.ip = "10.100.0.4/24";
    };

    networking = {
      dhcpcd = {
      #  wait = mkForce "ipv4"; # don't wait. That would take longer
        persistent = true;
      };

      #interfaces.enp1s0.useDHCP = true;
    };
    networking.networkmanager.enable = true;

    # clean logs older than 2d
    services.cron.systemCronJobs = [
      "0 20 * * * root journalctl --vacuum-time=2d"
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
  };
}
