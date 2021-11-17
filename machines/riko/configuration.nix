{ self, inputs, pkgs, lib, ... }:

with inputs;
let
  settings = import ../../settings;
in {

  imports = [
    ./hardware-configuration.nix
    base16.hmModule
  ];

  machine = {
    autologin-tty1 = true;
    bluetooth = true;
    encryptedRoot = true;
    lowLevelXF86keys.enable = true;
    quietBoot = true;
    sound = true;
    sway = true;
  };

  starbase = {
    printerScanner = true;
  };

  networking.hostName = "riko";
  nix.maxJobs = lib.mkDefault 4;

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  #networking.firewall.allowedUDPPorts = [ 5353 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
