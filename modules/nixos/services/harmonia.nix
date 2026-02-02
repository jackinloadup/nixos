{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.services.harmonia;
in
{
  config = mkIf cfg.enable {
    services.harmonia = {
      signKeyPaths = [ config.age.secrets.nix-signing-key.path ];
      settings.bind = "127.0.0.1:5050";
    };

    services.nginx.virtualHosts."cache.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5050";
        extraConfig = ''
          proxy_cache off;
          proxy_buffering off;
        '';
      };
    };
  };
}
