{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  options.machine.minimal = mkEnableOption "Disable stuff not needed on minimal systems";

  config = mkIf cfg.minimal {
    networking.networkmanager.plugins = mkDefault [];

    #environment.systemPackages = with pkgs; [

    #environment.noXlibs = mkDefault true;

    # Size reduction

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
