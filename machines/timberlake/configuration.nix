{ lib, inputs, ... }:
let
  inherit (lib) mkDefault mkForce;
  isUserFacing = false;
in
{
  imports = [
    inputs.self.nixosModules.default
    inputs.self.nixosModules.lriutzelTui
    ./hardware-configuration.nix
    ./home-assistant.nix
  ];

  config = {

    boot.initrd = {
      systemd.emergencyAccess = true;
    };
    #-----------------------------------
    boot.plymouth.enable = isUserFacing;
    boot.initrd.verbose = !isUserFacing;

    #boot.initrd.network.tor.enable = true;
    #boot.initrd.network.ntpd.enable = true;
    #boot.initrd.network.ntpd.address = "5.78.71.97"; # ip of 0.north-america.pool.ntp.org

    hardware.bluetooth.enable = isUserFacing;

    services.fwupd.enable = mkForce true;

    services.pipewire.enable = isUserFacing;

    services.jellyfin = {
      enable = true;
      openFirewall = false; # handle http via nginx
    };

    # tcp is handled via nginx
    networking.firewall.allowedUDPPorts = [
      1900
      7359
    ];

    services.nginx.virtualHosts."jellyfin.timberlake.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://localhost:8096/";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."ha.timberlake.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://localhost:8123/";
        proxyWebsockets = true;
      };
    };

    machine = {
      # TODO make this user more minimal
      users = mkDefault [ ];
      sizeTarget = 2; # was 1
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

      vpn.server.endpoint = "vpn.lucasr.com:51820";
      vpn.client.enable = true;
      vpn.client.ip = "10.100.0.8/24";
    };

    virtualisation = rec {
      vmVariant = {
        networking.hostName = mkForce "timberlake-vm";
        #services.xserver.displayManager.defaultSession = mkForce "none+i3";
        boot.initrd.kernelModules = [ ];

        virtualisation = {
          #useEFIBoot = true;
          #useBootLoader = true;

          # https://github.com/NixOS/nixpkgs/issues/59219
          cores = 4;
          graphics = true;
          memorySize = 2048;
          qemu.networkingOptions = [ "-nic bridge,br=br0,model=virtio-net-pci,mac=30:9c:23:01:2f:82,helper=/run/wrappers/bin/qemu-bridge-helper" ];
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
        };
      };

      vmVariantWithBootLoader = vmVariant;
    };

    networking.dhcpcd.persistent = true;
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
    system.stateVersion = "24.11"; # Did you read the comment?
  };
}
