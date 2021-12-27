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
    }
  ];

  # Make user available in user list
  options.machine.users = mkOption {
    type = with types; listOf (enum [ "lriutzel" ]);
  };

  # If user is enabled
  config = mkIf (cfg.sizeTarget > 0 && builtins.elem "lriutzel" config.machine.users) {
    nix.trustedUsers = [ "lriutzel" ];

    users.users.lriutzel = with settings; {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "audio"
        "video"
        "networkmanager"
        "wireshark"
      ];
    };

    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.users.lriutzel = import ../../home-manager;

    programs.wireshark.enable = true;
    # #TODO figure out how to enable only at user level
    #programs.gnupg.agent = {
    #  enable = true;
    #  enableSSHSupport = true;
    #};

    services.trezord.enable = if (cfg.sizeTarget > 1) then true else false; # Support Trezor

    environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 1) [
      unstable.mqttui # mqtt tui
    ];

    hardware.yubikey.enable = ifGraphical;
    # #TODO figure out how to enable only at user level
    #programs.gnupg.agent = {
    #  enable = true;
    #  enableSSHSupport = true;
    #};
  };
}
