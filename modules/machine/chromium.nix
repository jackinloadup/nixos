{ lib, pkgs, config, ... }:

# If extraOpts can be expressed in home-manager that
# would be more ideal or at least an alterate if using
# nix seporate from nixos

with lib;
{
  imports = [ ];

  options.machine.chromium = mkEnableOption "Enable extra options only needed for gaming";

  config = mkIf config.machine.chromium {
    environment.systemPackages = with pkgs; [
      chromium
    ];

    programs.chromium = {
      enable = true; # enable policies doesn't install chromium
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
  };

}

