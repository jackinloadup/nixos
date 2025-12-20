{ config
, flake
, lib
, ...
}:
# Machine is a work computer for obsidian.systems
let
  inherit (lib) mkForce mkDefault;
in
{
  imports = [
    flake.self.nixosModules.common
    flake.self.nixosModules.linux
    flake.self.nixosModules.tui
    flake.self.nixosModules.gumdrop
    flake.self.nixosModules.gui
    flake.self.nixosModules.work
    flake.self.nixosModules.lriutzelGui
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

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    networking.dhcpcd.persistent = true;


    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?

  };
}
