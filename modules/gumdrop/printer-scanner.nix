{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
  printer = {
    make = "Brother";
    model = "MFC-9130CW"; 
    address = "printer.home.lucasr.com";
    location = "Office";
  };
in {
  imports = [];

  options.gumdrop.printerScanner = mkEnableOption "Setup using the printer and scanner";

  config = mkIf config.gumdrop.printerScanner {
    environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 0) [
      gnome.simple-scan
    ];

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers = with pkgs; [ cups-filters ];

    hardware.printers.ensurePrinters = with printer; [
      {
        name = "${make}_${model}";
        deviceUri = "ipp://${address}:631/ipp";
        location = location;
        #model = "brother-BrGenML1-cups-en.ppd";
        model = "everywhere";
        ppdOptions = {
          PageSize = "US Letter";
        };
      }
    ];

    # Enable Sane to scan documents.
    hardware.sane.enable = true;
    hardware.sane.brscan4.enable = true;
    hardware.sane.brscan4.netDevices = with printer; {
      "Home" = {
        "ip" = "10.16.1.64";
        "model" = model;
      };
    };

    users.users = with settings.user; {
      ${username} = {
        extraGroups = [ "scanner" "lp" ];
      };
    };
  };
}
