{ inputs, lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  home-manager = inputs.home-manager;
  settings = import ./settings.nix;
  ifGraphical = if (cfg.sizeTarget > 1) then true else false;
in {
  imports = [
    home-manager.nixosModules.home-manager {
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
    }
  ];

  # Make user available in user list
  options.machine.users = mkOption {
    type = with types; listOf (enum [ "lriutzel" ]);
  };

  # If user is enabled
  config = mkIf (builtins.elem "lriutzel" config.machine.users) {
    nix.trustedUsers = [ "lriutzel" ];

    users.users.lriutzel = with settings; {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "audio"
        "video"
        "input"
        "networkmanager"
        "wireshark"
        #dip netdev plugdev 
        # cdrom floppy
      ];
    };

    environment.etc."nixos/flake.nix".source = "/home/lriutzel/dotfiles/flake.nix";

    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.users.lriutzel = {
      imports = [
        ../../home-manager
      ];
      programs.git.extraConfig.safe.directory = "/home/lriutzel/dotfiles";
    };

    programs.wireshark.enable = ifGraphical;

    services.trezord.enable = true;

    environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 1) [
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language
      emulsion # mimimal linux image viewer built in rust
      nmap-graphical
      fzf

      #nur.repos.milahu.aether-server # Peer-to-peer ephemeral public communities

      unstable.mqttui # mqtt tui

      unstable.helvum # pipewire patchbay
      easyeffects
      trezorctl
    ];

    hardware.yubikey.enable = ifGraphical;

    # #TODO figure out how to enable only at user level
    #programs.gnupg.agent = {
    #  enable = true;
    #  enableSSHSupport = true;
    #};
    modules.browsers.firefox = {
      enable = true;
      profileName = "lriutzel";
    };

  };
}
