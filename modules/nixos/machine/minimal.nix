{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.machine;
in {
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

    ## Remove documentation
    documentation.enable = mkDefault false;
    documentation.nixos.enable = mkDefault false;
    documentation.nixos.includeAllModules = mkDefault false; # default is mkDefault false just wanted to note
    documentation.man.enable = mkDefault false;
    documentation.info.enable = mkDefault false;
    documentation.doc.enable = mkDefault false;

    ## Disable udisks, sounds, …
    services.udisks2.enable = mkDefault false;
    xdg.sounds.enable = mkDefault false;
  };
}
