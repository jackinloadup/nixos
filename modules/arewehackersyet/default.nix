{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];

  options.machine = {
    # https://jjjollyjim.github.io/arewehackersyet/index.html
    arewehackersyet = mkEnableOption "Tools from kali linux" ;
  };

  config = mkIf cfg.arewehackersyet {
      environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 0) [
        gnome.simple-scan
       	aircrack-ng 
        wifite2
        bully
        cowpatty
        hashcat
        kismet
        macchanger
        pixiewps
        ccrypt
        steghide
        mdbtools
        sqlitebrowser
        beef
        metasploit
        apktool
        exiv2
        ext4magic
        extundelete
        yara
        sslsplit
        sslscan
        sslh
        ssldump
        wpscan
        zap
        siege
        redsocks
        proxytunnels
        proxychains
        nmap
        httrack
        thc-hydra
        dirb
        cadaver
        burpsuite
      ];
  };
}
