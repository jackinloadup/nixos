{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.machine;
  settings = import ../../../settings;
in {
  imports = [
    ./printer-scanner.nix
    ./pihole.nix
    ./scanned-document-handling.nix
    ./storage-server.nix
    ./vpn.nix
  ];

  config = {
    # may not be nessisary if multiple dhcp search/domain things stack
    # as the machine is connected to more networks
    networking.search = ["home.lucasr.com"];
    networking.domain = "home.lucasr.com";

    # set logitec mouse to autosuspend after 60 seconds
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="60000"
    '';
  };
}
