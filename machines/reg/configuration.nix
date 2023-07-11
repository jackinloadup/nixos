{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
with inputs; let
  settings = import ../../settings;
in {
  imports = [
    ./change-logitec-suspend.nix
    ./control-monitor-backlight.nix
    ./hardware-configuration.nix
    ./rename-pipewire-sinks.nix
    ./sway-monitor-setup.nix
  ];

  boot.initrd.verbose = false;
  boot.plymouth.enable = false;

  hardware.bluetooth.enable = true;
  hardware.rtl-sdr.enable = true;
  hardware.yubikey.enable = true;

  programs.adb.enable = true;
  programs.chirp.enable = true;
  programs.chromium.enable = true;
  programs.steam.enable = true;
  programs.simula.enable = false;

  services.hydra.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  services.kubo.enable = true;
  services.kubo.settings.Addresses.API = "/ip4/127.0.0.1/tcp/5001";

  services.nextcloud.enable = false;
  services.pipewire.enable = true;

  services.rtl_433 = {
    enable = false;
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

  # xdg-desktop-portal-gnome 44 causes delays in non-GNOME desktops
  #     https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome/-/issues/74
  #services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.windowManager.i3.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  machine = {
    users = [
      "lriutzel"
    ];
    tui = true;
    sizeTarget = 3;
    encryptedRoot = true;
    gaming = true;
    impermanence = true;
    lowLevelXF86keys.enable = true;
    displayManager = "greetd";
    windowManagers = ["sway"];
    locale = settings.user.locale;
    characterSet = settings.user.characterSet;
  };

  # Causes kernel build
  boot.crashDump.enable = false;

  boot.binfmt.emulatedSystems = [
    "wasm32-wasi"
    "x86_64-windows"
    "aarch64-linux"
  ];

  # dragon, doesn't look too good in tty only works in pty
  environment.etc.issue.source = lib.mkForce ./issue-banner;

  gumdrop = {
    printerScanner = true;
    storageServer.enable = true;
    storageServer.media = true;
    storageServer.roms = true;
  };

  nix.settings.max-jobs = lib.mkDefault 16;

  nixpkgs.overlays = [
    inputs.nur.overlay
    inputs.self.overlays.default
    inputs.self.overlays.kodi-wayland
  ];

  networking.hostName = "reg";
  networking.bridges.br0.interfaces = ["eno1"];
  networking.interfaces.br0.useDHCP = true;
  virtualisation.libvirtd.allowedBridges = ["br0"];

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
