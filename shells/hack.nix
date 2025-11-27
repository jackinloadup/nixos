{ pkgs ? import <nixpkgs> {}, ... }:

# https://jjjollyjim.github.io/arewehackersyet/index.html
pkgs.mkShell {
  name = "Tools from kali linux";

  packages = [
    pkgs.aircrack-ng
    pkgs.wifite2
    pkgs.bully
    pkgs.cowpatty
    pkgs.hashcat
    pkgs.kismet
    pkgs.macchanger
    pkgs.pixiewps
    pkgs.ccrypt
    pkgs.steghide
    pkgs.mdbtools
    pkgs.sqlitebrowser
    #pkgs.beef
    pkgs.metasploit
    pkgs.apktool
    pkgs.exiv2
    pkgs.ext4magic
    pkgs.extundelete
    pkgs.yara
    pkgs.sslsplit
    pkgs.sslscan
    pkgs.sslh
    pkgs.ssldump
    pkgs.wpscan
    pkgs.zap
    pkgs.siege
    pkgs.redsocks
    #pkgs.proxytunnels
    pkgs.proxychains
    pkgs.nmap
    pkgs.httrack
    pkgs.thc-hydra
    pkgs.dirb
    pkgs.cadaver
    pkgs.burpsuite
  ];
}
