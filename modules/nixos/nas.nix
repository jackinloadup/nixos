{ lib
, config
, pkgs
, ...
}:
let
  inherit (lib) mkDefault mkIf mkEnableOption;
  cfg = config.services.nas;
in
{
  options.services.nas = {
    enable = mkEnableOption "Setup nixos for media nas";
  };

  config = mkIf cfg.enable {
    services.openssh.enable = mkDefault true;

    services.mullvad-vpn.enable = true;

    # install version with GUI
    services.mullvad-vpn.package = pkgs.mullvad-vpn;

    ## auto standby
    #services.cron.systemCronJobs = [
    #    "0 1 * * * root rtcwake -m mem --date +6h"
    #];

    ## samba service
    #services.samba.enable = true;
    #services.samba.enableNmbd = true;
    #services.samba.extraConfig = ''
    #      workgroup = WORKGROUP
    #      server string = Samba Server
    #      server role = standalone server
    #      log file = /var/log/samba/smbd.%m
    #      max log size = 50
    #      dns proxy = no
    #      map to guest = Bad User
    #  '';
    #services.samba.shares = {
    #    public = {
    #        path = "/home/public";
    #        browseable = "yes";
    #        "writable" = "yes";
    #        "guest ok" = "yes";
    #        "public" = "yes";
    #        "force user" = "share";
    #      };
    #   };
    #
    ## minidlna service
    #services.minidlna.enable = true;
    #services.minidlna.announceInterval = 60;
    #services.minidlna.friendlyName = "Rorqual";
    #services.minidlna.mediaDirs = ["A,/home/public/Musique/" "V,/home/public/Videos/"];
    #
    ## trick to create a directory with proper ownership
    ## note that tmpfiles are not necesserarly temporary if you don't
    ## set an expire time. Trick given on irc by someone I forgot the name..
    #systemd.tmpfiles.rules = [ "d /home/public 0755 share users" ];
    #
    ## create my user, with sudo right and my public ssh key
    #users.users.solene = {
    #  isNormalUser = true;
    #  extraGroups = [ "wheel" "sudo" ];
    #  openssh.authorizedKeys.keys = [
    #        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIZKLFQXVM15viQXHYRjGqE4LLfvETMkjjgSz0mzMzS personal"
    #        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIZKLFQXVM15vAQXBYRjGqE6L1fvETMkjjgSz0mxMzS pro"
    #  ];
    #};
    #
    ## create a dedicated user for the shares
    ## I prefer a dedicated one than "nobody"
    ## can't log into it
    #users.users.share= {
    #  isNormalUser = false;
    #};
  };
}
