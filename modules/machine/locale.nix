{ lib, pkgs, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];

  options.machine = {
    locale = mkOption {
      type = types.str;
      default = "en_US";
      example = "en_US";
      description = "Locale";
    };
    characterSet = mkOption {
      type = types.str;
      default = "UTF-8";
      example = "UTF-8";
      description = "Character Set";
    };
  };

  config = {
    # Select and limit locales
    i18n = with settings.user;
    let
      localeFull = "${cfg.locale}.${cfg.characterSet}";
      localeExtended = "${localeFull}/${cfg.characterSet}";
    in {
      supportedLocales = [ localeExtended ];
      defaultLocale = localeFull;
      glibcLocales = pkgs.glibcLocales.override {
        allLocales = false;
        locales = [ localeExtended ];
      };
    };
  };
}
