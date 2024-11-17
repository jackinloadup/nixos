{
  self,
  pkgs,
  lib,
  flake,
  config,
  ...
}:
let
  inherit (lib) mkDefault mkForce;
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
    ./monitor-setup.nix
    ./rtl_433.nix
    ./iwd.nix
    ./wg-vpn.nix
  ];

  boot.plymouth.enable = true;
  boot.initrd.verbose = false;

  hardware.bluetooth.enable = true;
  hardware.yubikey.enable = true;


  home-manager.sharedModules = [
    {
      wayland.windowManager.sway.enable = config.programs.sway.enable;
      wayland.windowManager.hyprland.enable = config.programs.hyprland.enable;
      services.satellite-images.enable = true;

      programs.wpaperd = {
        enable = true;
        settings.default = {
          #path = "${config.xdg.cacheHome}/satellite-images/goes-east/current";
          path = "~/.cache/satellite-images/goes-east/current.jpg";
        };
      };
    }
  ];

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  programs.sway.enable = true;
  programs.steam.enable = true;

  services.fprintd.enable = true;
  services.kubo.enable = true;
  services.kubo.settings.Addresses.API = "/ip4/127.0.0.1/tcp/5001";
  services.pipewire.enable = true;

  #services.displayManager.enable = true; # enable systemd’s display-manager service
  #services.displayManager.sddm.enable = true;

 # services.xserver.displayManager.autoLogin.enable = true;
 # services.xserver.displayManager.autoLogin.user = "lriutzel";
 # services.xserver.displayManager.defaultSession = "sway";
  services.xserver.displayManager.gdm.enable = true;

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.windowManager.i3.enable = true;

  security.polkit.enable = true;

  machine = {
    users = ["lriutzel" "criutzel"];
    tui = true;
    sizeTarget = 2;
    encryptedRoot = true;
    lowLevelXF86keys.enable = true;
    gaming = true;
  };
  #programs.sway.enable = true;

  gumdrop = {
    printerScanner = true;
    storageServer.enable = false;
    storageServer.media = true;
    storageServer.roms = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  networking.hostName = "riko";

  # update to nixos-unified is setting this to auto
  #nix.settings.max-jobs = mkDefault 4;

  nixpkgs.hostPlatform = "x86_64-linux";

  nixpkgs.overlays = [
    flake.inputs.self.overlays.default
    #flake.inputs.self.overlays.kodi-wayland
  ];
  #fonts.fontconfig.dpi = 152;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
