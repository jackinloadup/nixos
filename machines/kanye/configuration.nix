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
    # worked though
  #  ./change-logitec-suspend.nix
    ./iwd.nix
  ];

  boot.plymouth.enable = true;
  #boot.plymouth.themePackages = [ pkgs.adi1090x-plymouth-themes ];
  #boot.plymouth.theme = "colorful";

  ## plymouth alternative themes
  # colorful
  # colorful-loop
  # colorful-hud
  # owl
  # pixels
  # Polaroid
  # Rings-2
  # Sphere

  boot.initrd.verbose = false;

  hardware.bluetooth.enable = true;
  hardware.yubikey.enable = mkDefault true;
  hardware.logitech.wireless.enable = mkDefault true;
  hardware.logitech.wireless.enableGraphical = mkDefault true;

  services.pipewire.enable = true;

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "criutzel";
  services.xserver.displayManager.defaultSession = "gnome";
  services.xserver.displayManager.gdm.enable = true;

  services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.windowManager.i3.enable = true;

  machine = {
    users = ["lriutzel" "criutzel"];
    tui = true;
    sizeTarget = 2;
    lowLevelXF86keys.enable = true;
    gaming = true;
    impermanence = true;
  };

  gumdrop = {
    printerScanner = true;
    storageServer.enable = true;
    storageServer.media = true;
    storageServer.roms = true;

    vpn.server.endpoint = "home.lucasr.com:51820";
    vpn.client.enable = true;
    vpn.client.ip = "10.100.0.5/24";
  };

  powerManagement.cpuFreqGovernor = "powersave";

  networking.hostId = "aa0431f3";
  networking.hostName = "kanye";

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
