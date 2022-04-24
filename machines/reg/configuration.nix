{ self, inputs, pkgs, lib, ... }:

with inputs;
let
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
    ./rename-pipewire-sinks.nix
    ./sway-monitor-setup.nix
    ./change-logitec-suspend.nix
    ./control-monitor-backlight.nix
    base16.hmModule
  ];

  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "lriutzel";
  services.xserver.displayManager.defaultSession = "sway";

  machine = {
    users = [
      "lriutzel"
    ];
    adb = true;
    chirp = true;
    chromium = true;
    docker = true;
    tui = true;
    sizeTarget = 2;
    bluetooth = true;
    botamusique = false;
    encryptedRoot = true;
    gaming = true;
    lowLevelXF86keys.enable = true;
    quietBoot = true;
    simula = true;
    sdr = true;
    sound = true;
    steam = true;
    displayManager = "greetd";
    windowManagers = [ "sway" "i3" ];
    virtualization = true;
    locale = settings.user.locale;
    characterSet = settings.user.characterSet;
  };

  environment.etc.issue.source = lib.mkForce ./issue-banner;

  gumdrop = {
    printerScanner = true;
    storageServer = true;
  };

  networking.hostName = "reg";
  nix.maxJobs = lib.mkDefault 16;

  #networking.firewall.allowedTCPPorts = [ 8000 ]; # What is port 8000 for?
  #networking.firewall.allowedUDPPorts = [ 8000 ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  # List services that you want to enable:


  hardware.opengl.extraPackages = with pkgs; [
    radeontop #  Top for amd cards. Could maybe be placed somewhere else? debug only if possible?
    radeon-profile
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
