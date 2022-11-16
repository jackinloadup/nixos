{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
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
    environment.systemPackages = with pkgs; [
      gnome.simple-scan
    ];

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers = with pkgs; [ cups-filters mfc9130cwlpr mfc9130cwcupswrapper ];

    services.colord.enable = true;

    hardware.printers.ensurePrinters = with printer; [
      {
        name = "${make}_${model}";
        deviceUri = "ipp://${address}:631/ipp";
        location = location;
        #model = "everywhere"; # keeping for reference for any future printers in a pinch
        model = "Brother/brother_mfc9130cw_printer_en.ppd";
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

    users.users = addExtraGroups normalUsers [ "scanner" "lp" ];
  };
}
