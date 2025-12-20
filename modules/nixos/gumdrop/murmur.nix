{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.murmur.enable {
    services.murmur = {
      openFirewall = true;
      registerHostname = "mumble.lucasr.com";
      registerName = "Ramble Rable";
      stateDir = "/var/lib/murmur";
      welcometext = "A place chat";

      sslKey = "${config.security.acme.certs."mumble.lucasr.com".directory}/key.pem";
      sslCert = "${config.security.acme.certs."mumble.lucasr.com".directory}/fullchain.pem";

    };

    security.acme.certs."mumble.lucasr.com" = {
      email = "lriutzel@gmail.com";
      group = config.services.murmur.group;
    };

    #services.nginx.virtualHosts."mumble.lucasr.com" = {
    #  forceSSL = true;
    #  enableACME = true;
    #  acmeRoot = null; # Use DNS Challenege
    #};
  };
}
