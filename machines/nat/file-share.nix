{ lib
, config
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.gumdrop.scanned-document-handling.enable = mkEnableOption "Setup services to handle scanned document collection and handling";
  config = mkIf config.gumdrop.scanned-document-handling.enable {

    #TODO must define gid and uid
    users.users.serviceftp = {
      isSystemUser = true;
      group = "serviceftp";
      extraGroups = [ "vsftpd" ];
      home = "/mnt/gumdrop/printerScanShare";
    };

    users.groups.serviceftp = { };

    networking.firewall = {
      allowedTCPPorts = [ 21 ]; # ftp
      allowedTCPPortRanges = [{ from = 56250; to = 56260; }];
    };

    #systemd.tmpfiles.rules = [ "d /var/ftp 2770 vsftpd vsftpd - -" ];

    services.vsftpd = {
      enable = true;

      extraConfig = ''
        pasv_enable=Yes
        pasv_min_port=56250
        pasv_max_port=56260

        local_umask=000
      '';

      localUsers = true;
      userlist = [ "serviceftp" ];
      chrootlocalUser = true;

      localRoot = "/mnt/gumdrop/printerScanShare";

      allowWriteableChroot = true;
      writeEnable = true;

      #anonymousUserHome = "/mnt/gumdrop/printerScanShare";
      #anonymousUser = true;
      #anonymousMkdirEnable = true;
      #anonymousUploadEnable = true;

    };

    #services.tika = {
    #  enable = true;
    #};

  };

}
