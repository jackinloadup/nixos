{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  imports = [];


  options.machine.sdr = mkEnableOption "Enable SDR platform";

  config = mkIf cfg.sdr {
    hardware.rtl-sdr.enable = true;

    users.users = addExtraGroups normalUsers [ "plugdev" ];

    environment.systemPackages = with pkgs; [
      cubicsdr
      gnuradio # there is a minimal version
      sdrangel
      nrsc5
      gqrx
    ];
  };
}
