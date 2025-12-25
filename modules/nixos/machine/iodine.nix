{ pkgs
, lib
, ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.iodined.enable {
    # https://github.com/yarrick/iodine
    environment.systemPackages = [
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language
      pkgs.iodine # mimimal linux image viewer built in rust
    ];
    networking.firewall.allowedUDPPorts = [ 53 ];
    services.iodined = {
      domain = "dns.home.lucasr.com";
    };
  };
}
