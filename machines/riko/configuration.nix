{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
with inputs; let
  inherit (lib) mkDefault;
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
  ];
  boot.initrd.verbose = false;

  hardware.bluetooth.enable = true;
  hardware.rtl-sdr.enable = true;
  hardware.yubikey.enable = true;

  programs.adb.enable = true;
  programs.chromium.enable = true;
  programs.steam.enable = true;

  services.kubo.enable = true;
  services.kubo.settings.Addresses.API = "/ip4/127.0.0.1/tcp/5001";
  services.pipewire.enable = true;

  services.rtl_433 = {
    enable = true;
    package = pkgs.rtl_433-dev;
    configText = ''
      output json
      output mqtt://mqtt.home.lucasr.com,user=mosquitto,pass=mosquitto,retain=0,events=rtl_433[/model][/id]
      report_meta time:utc
      frequency 915M
      frequency 433.92M
      convert si
      hop_interval 60
      gain 0
    '';
  };

  #services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "lriutzel";
  services.xserver.displayManager.defaultSession = "sway";
  #services.xserver.displayManager.gdm.enable = true;

  #services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.windowManager.i3.enable = true;

  # explore virtualisation.kvmgt.enable for intel gpu sharing into vm
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  machine = {
    users = ["lriutzel"];
    tui = true;
    sizeTarget = 2;
    encryptedRoot = true;
    lowLevelXF86keys.enable = true;
    gaming = true;
    displayManager = "greetd";
    windowManagers = ["sway"];
  };

  gumdrop = {
    printerScanner = true;
    storageServer.enable = true;
    storageServer.media = true;
    storageServer.roms = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  networking.hostName = "riko";

  # Playing with iwd
  environment.systemPackages = [pkgs.iwgtk];
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

  nix.settings.max-jobs = mkDefault 4;

  nixpkgs.overlays = [
    inputs.self.overlays.default
    #inputs.self.overlays.kodi-wayland
  ];
  #fonts.fontconfig.dpi = 152;

  services.logind.lidSwitch = "suspend-then-hibernate";
  #services.logind.lidSwitch = "hibernate";

  #services.upower.enable = true;
  #services.upower.criticalPowerAction = "Hibernate";

  ## Enable general power saving features.
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  hardware.brillo.enable = true;
  services.acpid = {
    enable = true;
    handlers = {
      ac-power = {
        action = ''
          vals=($1)  # space separated string to array of multiple values
          case ''${vals[3]} in
              00000000)
                  echo unplugged >> /tmp/acpi.log
                  ${pkgs.brillo}/bin/brillo -e -S 50
                  ;;
              00000001)
                  echo plugged in >> /tmp/acpi.log
                  ${pkgs.brillo}/bin/brillo -e -S 100
                  ;;
              *)
                  echo unknown >> /tmp/acpi.log
                  ;;
          esac
        '';
        event = "ac_adapter/*";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
