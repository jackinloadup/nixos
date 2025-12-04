{
  config,
  lib,
  ...
}:
# Machine is a work computer for obsidian.systems
let
  inherit (lib) mkForce mkDefault;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    boot.plymouth.enable = true;
    boot.initrd.verbose = false;

    hardware.bluetooth.enable = true;

    home-manager.sharedModules = [
      {
        wayland.windowManager.sway.enable = config.programs.sway.enable;
        wayland.windowManager.hyprland.enable = config.programs.hyprland.enable;
        programs.niri.enable = config.programs.niri.enable;

        services.wpaperd = {
          enable = true;
          settings.default = {
            path = "~/Pictures/Wallpapers";
            sorting = "random";
            duration = "5m";
          };
        };
      }
    ];

    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;
    programs.niri.enable = true;

    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "lriutzel";
    services.displayManager.defaultSession = "niri";

    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?

  };
}
