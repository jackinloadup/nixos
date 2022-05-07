{ self, inputs, pkgs, lib, ... }:

with inputs;
let
  settings = import ../../settings;
in {

  imports = [
    ./hardware-configuration.nix
    base16.hmModule
  ];

  hardware.yubikey.enable = true;

  # explore virtualisation.kvmgt.enable for intel gpu sharing into vm

  machine = {
    users = [ "lriutzel" ];
    adb = true;
    chromium = true;
    tui = true;
    sizeTarget = 2;
    bluetooth = true;
    encryptedRoot = true;
    lowLevelXF86keys.enable = true;
    quietBoot = true;
    sdr = false;
    sound = true;
    steam = true;
    displayManager = "greetd";
    windowManagers = [ "sway" "i3" ];
    virtualization = true;
  };

  gumdrop = {
    printerScanner = true;
    storageServer = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  networking.hostName = "riko";
  nix.maxJobs = lib.mkDefault 4;
  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
  ];

  nixpkgs.overlays = [
    inputs.self.overlay
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

  # set logitec mouse to autosuspend after 60 seconds
  services.udev.extraRules = ''
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="60000"
  '';

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
