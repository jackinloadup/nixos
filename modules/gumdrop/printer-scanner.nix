{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];

  options.gumdrop.printerScanner = mkEnableOption "Setup using the printer and scanner";

  config = mkIf config.gumdrop.printerScanner {
    environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 0) [
      gnome.simple-scan
    ];

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers = with pkgs; [ brlaser cups-filters ];

    # Enable Sane to scan documents.
    hardware.sane.enable = true;
    hardware.sane.brscan4.enable = true;
    hardware.sane.brscan4.netDevices = {
      "Home" = {
        "ip" = "10.16.1.64";
        "model" = "MFC-9130CW";
      };
    };

    users.users = with settings.user; {
      ${username} = {
        extraGroups = [ "scanner" "lp" ];
      };
    };
  };
}
