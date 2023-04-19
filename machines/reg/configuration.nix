{ self, inputs, pkgs, lib, ... }:

with inputs;
let
  settings = import ../../settings;
in {
  imports = [
    ./change-logitec-suspend.nix
    ./control-monitor-backlight.nix
    ./hardware-configuration.nix
    ./rename-pipewire-sinks.nix
    ./sway-monitor-setup.nix
  ];

  #services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "lriutzel";
  services.xserver.displayManager.defaultSession = "sway";

  services.hydra.enable = true;
  services.nextcloud.enable = true;

  machine = {
    users = [
      "lriutzel"
    ];
    adb = true;
    chirp = true;
    chromium = true;
    docker = true;
    tui = true;
    sizeTarget = 3;
    bluetooth = true;
    botamusique = false;
    encryptedRoot = true;
    gaming = true;
    impermanence = true;
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

  # Causes kernel build
  boot.crashDump.enable = false;

  environment.etc.issue.source = lib.mkForce ./issue-banner;

  gumdrop = {
    printerScanner = true;
    storageServer.enable = true;
    storageServer.media = true;
    storageServer.roms = true;
  };

  networking.hostName = "reg";
  nix.settings.max-jobs = lib.mkDefault 16;

  nixpkgs.overlays = [
    inputs.nur.overlay
    inputs.self.overlays.default
    inputs.self.overlays.kodi-wayland
  ];

  networking.bridges.br0.interfaces = ["eno1"];
  networking.interfaces.br0.useDHCP = true;
  virtualisation.libvirtd.allowedBridges = [ "br0" ];

  #networking.firewall.allowedTCPPorts = [ 8000 ]; # What is port 8000 for?
  #networking.firewall.allowedUDPPorts = [ 8000 ];
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
