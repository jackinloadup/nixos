{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  #options.machine.mi = mkEnableOption "Hide boot log from tui/gui";

  config = mkIf (cfg.sizeTarget < 1) {
    #environment.systemPackages = with pkgs; [

    environment.noXlibs = mkDefault true;

    # Size reduction

    ## Limit the locales we use
    #i18n = {
    #  supportedLocales = [ "fr_FR.UTF-8/UTF-8" ];
    #  defaultLocale = "fr_FR.UTF-8/UTF-8";
    #  glibcLocales = pkgs.glibcLocales.override {
    #    allLocales = false;
    #    locales = [ "fr_FR.UTF-8/UTF-8" ];
    #  };
    #};

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
