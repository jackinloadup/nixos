{ config, pkgs, nixosConfig, lib, inputs, ... }:

let
  inherit (lib) mkIf;
  settings = import ../settings;
in {
  config = mkIf config.services.gpg-agent.enable {
    home.persistence."/persist/home/${config.home.username}" = {
      directories = [
        ".gnupg"
      ];
      allowOther = true;
    };

    programs.gpg = {
      enable = true;
      # .local/share/gnupg
      #homeDir = "${config.xdg.dataHome}/gnupg";
    };

    services = {
      gpg-agent = {
        enableExtraSocket = false;
        enableScDaemon = false;
        enableSshSupport = true;
        defaultCacheTtl = 30;
        defaultCacheTtlSsh = 30;
        maxCacheTtl = 3600; # 1 hour
        maxCacheTtlSsh = 3600; # 1 hour
      };
    };
  };
}
