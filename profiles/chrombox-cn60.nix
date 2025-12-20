{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  config = {
    # machine isn't physically moving. Keep same dhcp issued address
    networking.networkmanager.wifi.macAddress = mkForce "permanent";
  };
}

