{ inputs, pkgs, config, lib, nixosConfig, ... }:

let
  inherit (lib) mkDefault;
  settings = import ../settings;
  ifGraphical = nixosConfig.machine.sizeTarget > 1;
in {
  imports = [ ];

  config = {
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = nixosConfig.system.stateVersion;

    xdg.enable = mkDefault true;

    programs.home-manager.enable = true;
  };
}
