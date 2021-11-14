{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  #options.machine.mi = mkEnableOption "Hide boot log from tui/gui";

  config = mkIf (cfg.sizeTarget < 1) {
    #environment.systemPackages = with pkgs; [

    environment.noXlibs = true;

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
    security.polkit.enable = false;

    programs.bash.enableCompletion = false;

    ## Remove documentation
    documentation.enable = false;
    documentation.nixos.enable = false;
    documentation.nixos.includeAllModules = false; # default is false just wanted to note
    documentation.man.enable = false;
    documentation.info.enable = false;
    documentation.doc.enable = false;

    ## Disable udisks, sounds, …
    services.udisks2.enable = false;
    xdg.sounds.enable = false;

  };
}
