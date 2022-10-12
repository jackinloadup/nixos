{ inputs, pkgs, config, lib, nixosConfig, ... }:

with lib;
let
  settings = import ../settings;
  ifGraphical = if (nixosConfig.machine.sizeTarget > 1) then true else false;
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
