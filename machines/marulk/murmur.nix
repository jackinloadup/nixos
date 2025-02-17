{ config, lib, ...}:
let
  inherit (lib) mkDefault;
in {
  config = {
    services.murmur = {
      enable = true;
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
