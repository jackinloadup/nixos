{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) attrNames mkIf mkEnableOption genAttrs types;
in {
  options.gumdrop.scanned-document-handling.enable = mkEnableOption "Setup services to handle scanned document collection and handling";
  config = mkIf config.gumdrop.scanned-document-handling.enable {

    # TODO: make services here depend on mount

    gumdrop.storageServer.backup = true;
    gumdrop.storageServer.printerScanShare = true;

    #TODO must define gid and uid
    users.users.serviceftp = {
      isSystemUser = true;
      group = "serviceftp";
      extraGroups = [ "vsftpd" ];
      home = "/mnt/gumdrop/printerScanShare";
    };

    users.groups.serviceftp = {};

    networking.firewall = {
      allowedTCPPorts = [ 21 ]; # ftp
      allowedTCPPortRanges = [ { from = 56250; to = 56260; } ];
    };

    #systemd.tmpfiles.rules = [ "d /var/ftp 2770 vsftpd vsftpd - -" ];

    # printer-scanner-share.home.lucasr.com in mikrotik dns points to this
    services.vsftpd = {
      enable = true;

      extraConfig = ''
        pasv_enable=Yes
        pasv_min_port=56250
        pasv_max_port=56260

        local_umask=000
      '';

      localUsers = true;
      userlist = ["serviceftp"];
      chrootlocalUser = true;

      localRoot = "/mnt/gumdrop/printerScanShare";

      allowWriteableChroot = true;
      writeEnable = true;

      #anonymousUserHome = "/mnt/gumdrop/printerScanShare";
      #anonymousUser = true;
      #anonymousMkdirEnable = true;
      #anonymousUploadEnable = true;

    };

    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      #address = "paperless.home.lucasr.com";
      mediaDir = "/mnt/gumdrop/backup/paperless";
      consumptionDir = "/mnt/gumdrop/printerScanShare";
      #exporter = {
      #  enable = true;
      #  #directory = "/mnt/gumdrop/backup/paperless";
      #  settings = {
      #    compare-checksums = true;
      #    delete = true;
      #    no-color = true;
      #    no-progress-bar = true;
      #  };
      #};
      settings = {
        PAPERLESS_ALLOWED_HOSTS = "paperless.home.lucasr.com,localhost";
        PAPERLESS_CSRF_TRUSTED_ORIGINS =
          "https://paperless.home.lucasr.com,http://localhost";
        PAPERLESS_CORS_ALLOWED_HOSTS =
          "https://paperless.home.lucasr.com,http://localhost";
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };

    #services.tika = {
    #  enable = true;
    #};

  };

}
