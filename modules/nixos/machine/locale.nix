_:
let
  settings = import ../../../settings;
in
{
  imports = [ ];

  config = {
    # Select and limit locales
    i18n = with settings.user; let
      localeFull = "${locale}.${characterSet}";
      localeExtended = "${localeFull}/${characterSet}";
    in
    {
      supportedLocales = [ localeExtended ];
      defaultLocale = localeFull;
      # use default
      #glibcLocales = pkgs.glibcLocales.override {
      #  allLocales = false;
      #  locales = [localeExtended];
      #};
    };
  };
}
