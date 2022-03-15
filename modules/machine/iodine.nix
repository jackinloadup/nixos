{ self, inputs, pkgs, lib, ... }:
let
  cfg = config.machine;
in {

  # https://github.com/yarrick/iodine
  environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 0) [ #nix-plugins # Collection of miscellaneous plugins for the nix expression language
    iodine # mimimal linux image viewer built in rust
  ];
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.iodined = {
    enable = true;
    domain = "dns.home.lucasr.com"
  };
}
