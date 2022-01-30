{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];

  options.gumdrop = {
    printerScanner = mkEnableOption "Setup printer scanner";
    storageServer = mkEnableOption "Setup connection to storage server";
  };

  config = mkMerge [
    (mkIf config.gumdrop.printerScanner {
      # may not be nessisary if multiple dhcp search/domain things stack 
      # as the machine is connected to more networks
      networking.search = [ "home.lucasr.com" ];
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
    })

    (mkIf config.gumdrop.storageServer {
      fileSystems."/gumdrop" = {
        device = "freenas.home.lucasr.com:/mnt/storage";
        fsType = "nfs";
        options = [
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=600" # disconnects after 10 minutes (i.e. 600 seconds)
        ];
      };
    })
  ];
}
