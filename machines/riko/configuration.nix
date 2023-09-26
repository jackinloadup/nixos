{
  self,
  pkgs,
  lib,
  flake,
  ...
}:
let
  inherit (lib) mkDefault mkForce;
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
    ./rtl_433.nix
    ./iwd.nix
  ];

  boot.plymouth.enable = true;
  boot.initrd.verbose = false;

  hardware.bluetooth.enable = true;
  hardware.rtl-sdr.enable = true;
  hardware.yubikey.enable = true;

  programs.steam.enable = true;

  services.kubo.enable = true;
  services.kubo.settings.Addresses.API = "/ip4/127.0.0.1/tcp/5001";
  services.pipewire.enable = true;

  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "lriutzel";
  #services.xserver.displayManager.defaultSession = "sway";
  services.xserver.displayManager.gdm.enable = true;

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.windowManager.i3.enable = true;

  machine = {
    users = ["lriutzel"];
    tui = true;
    sizeTarget = 2;
    encryptedRoot = true;
    lowLevelXF86keys.enable = true;
    gaming = true;
    #displayManager = "greetd";
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

  nix.settings.max-jobs = mkDefault 4;

  nixpkgs.hostPlatform = "x86_64-linux";

  nixpkgs.overlays = [
    flake.inputs.self.overlays.default
    #flake.inputs.self.overlays.kodi-wayland
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

  hardware.brillo.enable = true; # userspace brightness control for users in video group
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
