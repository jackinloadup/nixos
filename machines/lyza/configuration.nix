{
  self,
  flake,
  pkgs,
  lib,
  ...
}:
# machine runs ?
let
  inherit (lib) mkDefault mkForce;
  settings = import ../../settings;
  isUserFacing = false;
in {
  imports = [
    ./hardware-configuration.nix
    ./home-assistant.nix
  ];

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
#  systemd.network.wait-online.ignoredInterfaces = [ "lo" ];
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

  services.esphome = {
    enable = true;
    address = "0.0.0.0";
    openFirewall = true;
  };


  services.fwupd.enable = mkForce true;

  # doesn't seem to work
  #services.create_ap.enable = true;
  #services.create_ap.settings = {
  #  INTERNET_IFACE = "enp1s0";
  #  SSID = "ArtSpot";
  #  WIFI_IFACE = "wlan0";
  #};

  services.k3s.enable = false;
  services.k3s.role = "server";
  services.k3s.clusterInit = true;


  services.pipewire.enable = isUserFacing;
  #services.tor.enable = mkForce true;
  #services.tor.client.enable = mkForce true;

  #services.xserver.displayManager.autoLogin.user = "lriutzel";
  #services.xserver.displayManager.defaultSession = "sway";

  services.xserver.desktopManager.gnome.enable = isUserFacing;
  services.xserver.displayManager.gdm.enable = isUserFacing;

  #services.getty = {
  #  autologinUser = "kodi";
  #  extraArgs = [
  #    "--noissue"
  #    "--noclear"
  #    "--nohints"
  #    "--nohostname"
  #    "--skip-login"
  #  ];
  #};

  # Play with TPM. Hope to have ssh host key come from tpm.
  security.tpm2.enable = false;
  #security.tpm2.pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  #security.tpm2.tctiEnvironment.enable = true;  # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  #users.users.lriutzel.extraGroups = [ "tss" ];  # tss group has access to TPM devices

  machine = {
    users = mkDefault [
      "lriutzel"
    ];
    sizeTarget = 1; # was 1
    minimal = false;
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

    vpn.server.endpoint = "home.lucasr.com:51820";
    vpn.client.enable = true;
    vpn.client.ip = "10.100.0.4/24";
  };

  #nix.settings.max-jobs = mkDefault 8;

  nixpkgs = {
    overlays = [
      flake.inputs.nur.overlays.default
      flake.inputs.self.overlays.default
      #    inputs.self.overlays.plymouth-no-gtk
      #    inputs.self.overlays.pipewire-minimal
    ];
  };

  virtualisation = rec {
    vmVariant = {
      networking.hostName = mkForce "lyzavm";
      #services.xserver.displayManager.defaultSession = mkForce "none+i3";
      boot.initrd.kernelModules = [];

      virtualisation = {
        #useEFIBoot = true;
        #useBootLoader = true;

        # https://github.com/NixOS/nixpkgs/issues/59219
        cores = 4;
        graphics = true;
        memorySize = 2048;
        qemu.networkingOptions = ["-nic bridge,br=br0,model=virtio-net-pci,mac=30:9c:23:01:2f:82,helper=/run/wrappers/bin/qemu-bridge-helper"];
        qemu.options = [
          #"-device virtio-gpu-pci"
          #"-device virtio-gpu-gl-pci"
          "-device virtio-vga-gl"
          "-display gtk,gl=on"
          "-vga none"
        ];
      };

      networking.interfaces = mkForce {
        eth0.useDHCP = true;
        enp1s0f0.useDHCP = true;
      };
    };

    vmVariantWithBootLoader = vmVariant;
  };

  networking = {
    hostName = "lyza";
    hostId = "1a81f97a";

    dhcpcd = {
    #  wait = mkForce "ipv4"; # don't wait. That would take longer
      persistent = true;
    };

    #interfaces.enp1s0.useDHCP = true;
  };
  networking.networkmanager.enable = true;
  networking.wireless.enable = mkForce false;
  # Playing with iwd
  #environment.systemPackages = with pkgs; [ iwgtk ];
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    General = {
      AddressRandomization = "network";
      AddressRandomizationRange = "full";
      DisableANQP = false; # Hotspot 2.0 explore turning on
    };
    Network = {
      EnableIPv6 = true;
      RoutePriorityOffset = 300;
    };
    Settings = {
      AutoConnect = true;
      AlwaysRandomizeAddress = true;
    };
    Scan = {
      InitialPeriodicScanInterval = 1;
      MaximumPeriodicScanInterval = 60;
    };
  };

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
}
