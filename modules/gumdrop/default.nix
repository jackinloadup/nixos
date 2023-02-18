{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    ./adguard.nix
    ./printer-scanner.nix
    ./pihole.nix
    ./storage-server.nix
  ];

  config = {
    # may not be nessisary if multiple dhcp search/domain things stack
    # as the machine is connected to more networks
    networking.search = [ "home.lucasr.com" ];
    networking.domain = "home.lucasr.com";
  };
}
