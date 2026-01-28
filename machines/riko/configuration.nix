{ inputs, config, ... }:
{
  imports = [
    inputs.self.nixosModules.default
    inputs.self.nixosModules.lriutzelFull
    ./hardware-configuration.nix
    ./monitor-setup.nix
    ./iwd.nix
  ];

  config = {
    boot.plymouth.enable = true;
    boot.initrd.verbose = false;

    hardware.bluetooth.enable = true;

    home-manager.sharedModules = [
      {
        #wayland.windowManager.sway.enable = config.programs.sway.enable;
        #wayland.windowManager.hyprland.enable = config.programs.hyprland.enable;
        programs.niri.enable = config.programs.niri.enable;
        programs.claude-code.enable = true;

        services.satellite-images.enable = false;

        services.wpaperd = {
          enable = true;
          settings.default = {
            #path = "${config.xdg.cacheHome}/satellite-images/goes-east/current";
            #path = "~/.cache/satellite-images/goes-east/current.jpg";
            path = "~/Pictures/Wallpapers/nature";
            duration = "30m";
          };
        };
      }
    ];

    #programs.hyprland.enable = false;
    #programs.hyprland.xwayland.enable = true;
    programs.niri.enable = true;
    #programs.sway.enable = false;

    programs.steam.enable = true;

    services.fprintd.enable = true;
    services.kubo.enable = false;
    services.kubo.settings.Addresses.API = "/ip4/127.0.0.1/tcp/5001";
    services.pipewire.enable = true;

    #services.displayManager.enable = true; # enable systemd’s display-manager service

    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "lriutzel";
    services.displayManager.defaultSession = "niri";

    services.displayManager.gdm.enable = true;

    services.desktopManager.gnome.enable = true;
    services.xserver.windowManager.i3.enable = false;

    #services.resolved.enable = false;

    security.polkit.enable = true;

    #systemd.network.networks.wlan0.DHCP = "yes";

    machine = {
      users = [ "lriutzel" ];
      sizeTarget = 2;
      encryptedRoot = true;
      lowLevelXF86keys.enable = true;
      gaming = true;
      kexec.enable = true;
    };

    gumdrop = {
      printerScanner = true;
      storageServer.enable = true;
      storageServer.media = true;
      storageServer.roms = true;

      vpn.server.endpoint = "vpn.lucasr.com:51820";
      vpn.client.enable = true;
      vpn.client.ip = "10.100.0.3/24";

      nebula.client.enable = true;
      nebula.client.ip = "10.101.0.3/24";
    };

    powerManagement.cpuFreqGovernor = "powersave";

    # Not sure what I was using the bridge for. Going to disable for now.
    #networking.bridges.br0.interfaces = ["wlan0"];
    #networking.interfaces.br0.useDHCP = true;

    # update to nixos-unified is setting this to auto
    #nix.settings.max-jobs = mkDefault 4;

    #fonts.fontconfig.dpi = 152;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.05"; # Did you read the comment?

    home-manager.users.lriutzel.imports = [
      ./users/lriutzel/syncthing.nix
    ];
  };
}
