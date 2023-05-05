{
  inputs,
  pkgs,
  config,
  lib,
  nixosConfig,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = [];

  config = {
    # Home manager will have the same stateVersion as system
    home.stateVersion = nixosConfig.system.stateVersion;

    # enable management of XDG base directories
    xdg.enable = mkDefault true;

    programs.home-manager.enable = true;
  };
}
