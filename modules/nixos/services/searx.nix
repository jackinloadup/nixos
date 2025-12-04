{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf
in {
  config = mkIf config.services.searx.enable {
    services.searx = {

      settings = {
        general.debug = false; # breaks at runtime otherwise, somehow
        search = {
          safe_search = 0;
          autocomplete = "qwant";
          default_lang = "en-US";
          formats = [ "html" "json" ];
        };
        server = {
          #bind_address = "0.0.0.0";
          bind_address = "127.0.0.1";
          port = 7777;
          # not so secret yet
          secret_key = "37dd9e896bdb4b7cac32fd7f90867f87";
          image_proxy = false;
          default_locale = "en";
        };
        #ui.default_theme = "oscar";
        #ui.theme_args.oscar_style = "logicodev-dark";
        engines = lib.mapAttrsToList (name: value: {
          inherit name;
        } // value) {
            #"bitbucket".disabled = false;
            #"ccc-tv".disabled = false;
          "ddg definitions".disabled = false;
            #"erowid".disabled = false;
          "duckduckgo".disabled = false;
          "duckduckgo images".disabled = false;
          "fdroid".disabled = false;
          "gitlab".disabled = false;
            #"google play apps".disabled = false;
            #"nyaa".disabled = false;
          "openrepos".disabled = false;
            # "qwant".disabled = false;
          "reddit".disabled = false;
          "searchcode code".disabled = false;
            #"framalibre".disabled = false;
          "wikibooks".disabled = false;
          "wikinews".disabled = false;
          "wikiquote".disabled = false;
          "wikisource".disabled = false;
          "wiktionary".disabled = false;
        };
      };

      limiterSettings = {
        botdetection = {
          #x_for = 1;
          ipv4_prefix = 32;
          ipv6_prefix = 56;
          trusted_proxies = [
            "127.0.0.0/8"
            "::1"
          ];
        };

        botdetection.ip_lists.block_ip = [
          # "93.184.216.34" # example.org
        ];
      };
    };
  };
}
