{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) attrNames mkIf mkEnableOption genAttrs types;
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
    environment.systemPackages = [ pkgs.simple-scan ];

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers = [
      pkgs.cups-filters
      pkgs.mfc9130cwlpr
      pkgs.mfc9130cwcupswrapper
    ];

    services.colord.enable = true;

    systemd.services."paperless-task-queue.servicepaperless-scheduler.service".requires = ["network-online.target"];
    systemd.services."paperless-task-queue.service".requires = ["network-online.target"];

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

    users.users = addExtraGroups normalUsers ["scanner" "lp"];
  };
}
