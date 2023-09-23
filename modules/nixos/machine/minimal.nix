{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.machine;
in {
  #(inputs.nixpkgs + "nixos/modules/profiles/minimal.nix")
  options.machine.minimal = mkEnableOption "Disable stuff not needed on minimal systems";

  config = mkIf cfg.minimal {
    # Unsure if the following takes up space
    boot.enableContainers = mkDefault false;
    fonts.fontconfig.enable = mkDefault false;

    # Remove unnessisary vpn plugins mostly
    networking.networkmanager.plugins = mkDefault [];

    ## Remove polkit. It depends on spidermonkey !
    security.polkit.enable = mkDefault false;

    programs.bash.enableCompletion = mkDefault false;
  };
}
