{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    ./printer-scanner.nix
    ./storage-server.nix
  ];

  config = {
    # may not be nessisary if multiple dhcp search/domain things stack
    # as the machine is connected to more networks
    networking.search = [ "home.lucasr.com" ];
  };
}
