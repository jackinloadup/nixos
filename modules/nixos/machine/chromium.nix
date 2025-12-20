{ pkgs, ... }:
# If extraOpts can be expressed in home-manager that
# would be more ideal or at least an alternate if using
# nix separate from nixos
{
  config = {
    environment.systemPackages = [
      #chromium
      pkgs.ungoogled-chromium
    ];
    home-manager.sharedModules = [
      {
        programs.chromium.package = pkgs.ungoogled-chromium;
      }
    ];

    programs.chromium = {
      extraOpts = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "AutofillAddressEnabled" = true;
        "AutofillCreditCardEnabled" = false;
        "DefaultBrowserSettingEnabled" = false;
        "BuiltInDnsClientEnabled" = false;
        "MetricsReportingEnabled" = false;
        "SearchSuggestEnabled" = false;
        "CloudPrintSubmitEnabled" = false;
        "AlternateErrorPagesEnabled" = false;
        "UrlKeyedAnonymizedDataCollectionEnabled" = false;
        "DefaultSearchProviderSearchURL" = "https://duckduckgo.com/?q={searchTerms}";
        "DefaultSearchProviderSuggestURL" = "https://www.duckduckgo.com/qbox?query={searchTerms}";
        "BrowserThemeColor" = "#000000";
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "en-US"
        ];
      };
      extensions = [
        "dpjamkmjmigaoobjbekmfgabipmfilij" # Empty new tab page
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
        "njdfdhgcmkocbgbhcioffdbicglldapd" # LocalCDN
        "ckkdlimhmcjmikdlpkmbgfkaikojcbjk" # Markdown Viewer
        "cankofcoohmbhfpcemhmaaeennfbnmgp" # Netflix 1080p
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      ];
      defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
      defaultSearchProviderSuggestURL = "https://www.duckduckgo.com/qbox?query={searchTerms}";
    };

    security.chromiumSuidSandbox.enable = true;
  };
}
