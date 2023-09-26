{
  self,
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkForce getExe;
  settings = import ../../settings;
  debug = false;
in {
  imports = [
    ./change-logitec-suspend.nix
    ./control-monitor-backlight.nix
    ./hardware-configuration.nix
    ./rename-pipewire-sinks.nix
    ./sway-monitor-setup.nix
  ];

  boot.binfmt.emulatedSystems = [
    "wasm32-wasi"
    #"i686-embedded"
    "x86_64-windows"
    "aarch64-linux"
  ];
  boot.crashDump.enable = false; # Causes kernel build

  boot.initrd.network.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.network.tor.enable = true;
  boot.initrd.network.ntpd.enable = true;
  boot.initrd.network.ntpd.address = "5.78.71.97"; # ip of 0.north-america.pool.ntp.org

  boot.initrd.verbose = debug;
  boot.plymouth.enable = !debug;

  # dragon, doesn't look too good in tty only works in pty
  environment.etc.issue.source = mkForce ./issue-banner;

  hardware.bluetooth.enable = true;
  hardware.rtl-sdr.enable = true;

  home-manager.users.lriutzel.imports = [
    ./switch-desk.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  programs.steam.enable = true;
  programs.simula.enable = false;

  services.flatpak.enable = true;
  services.hydra.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  #services.k3s.enable = false;
  #services.k3s.role = "server";
  #services.k3s.clusterInit = true;

  services.kubo.enable = true;
  services.kubo.settings.Addresses.API = "/ip4/127.0.0.1/tcp/5001";

  #networking.firewall.allowedTCPPorts = [ 19999 ]; # netdata port;
  #services.netdata.enable = true; 

  services.pipewire.enable = true;

  #services.rtl_433 = {
  #  enable = false;
  #  package = pkgs.rtl_433-dev;
  #  configText = ''
  #    output json
  #    output mqtt://mqtt.home.lucasr.com,user=mosquitto,pass=mosquitto,retain=0,events=rtl_433[/model][/id]
  #    report_meta time:utc
  #    frequency 915M
  #    frequency 433.92M
  #    convert si
  #    hop_interval 60
  #    gain 0
  #  '';
  #};

  #services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "lriutzel";
  services.xserver.displayManager.defaultSession = "sway";
  #services.xserver.displayManager.gdm.enable = true;

  ## xdg-desktop-portal-gnome 44 causes delays in non-GNOME desktops
  ##     https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome/-/issues/74
  ##services.xserver.desktopManager.gnome.enable = true;
  ##services.xserver.windowManager.i3.enable = true;

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

  gumdrop = {
    printerScanner = true;
    storageServer.enable = true;
    storageServer.media = true;
    storageServer.roms = true;
  };

  nix.settings.max-jobs = lib.mkDefault 16;

  nixpkgs.overlays = [
    flake.inputs.nur.overlay
    flake.inputs.self.overlays.default
    flake.inputs.self.overlays.kodi-wayland
  ];

  networking.hostName = "reg";
  networking.bridges.br0.interfaces = ["eno1"];
  networking.interfaces.br0.useDHCP = true;
  networking.enableIPv6 = false;
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

  home-manager.sharedModules = [
    { 
      xdg.desktopEntries = {
        switch-to-savi-audio = {
          name = "Switch Audio to Savi";
          exec = "${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.usb-Plantronics_Savi_8220_008E6839CE254D13A0969E205B788648-01.analog-stereo";
          terminal = false;
          categories = [
            "Utility"
          ];
        };
        switch-to-desktop-audio = {
          name = "Switch Audio to Desktop";
          exec = "${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.pci-0000_1f_00.3.analog-stereo";
          terminal = false;
          categories = [
            "Utility"
          ];
        };
        monitor-light = {
          name = "Monitor Light";
          exec = "${getExe flake.inputs.scripts.packages.x86_64-linux.monitor-light}";
          terminal = false;
          categories = [
            "Utility"
          ];
        };
        monitor-dark = {
          name = "Monitor Dark";
          exec = "${getExe flake.inputs.scripts.packages.x86_64-linux.monitor-dark}";
          terminal = false;
          categories = [
            "Utility"
          ];
        };
      };
    }
  ];
}
