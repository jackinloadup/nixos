{ config
, pkgs
, lib
, ...
}:
let
  inherit (lib) mkIf;

  minsToSecs = mins: (mins * 60);
  hoursToSecs = hours: (hours * 60 * 60);
in
{
  config = mkIf config.services.gpg-agent.enable {
    programs.gpg = {
      enable = true;
      # .local/share/gnupg
      #homeDir = "${config.xdg.dataHome}/gnupg";
    };

    services.gpg-agent = {
      enableExtraSocket = false;
      enableScDaemon = false;
      enableSshSupport = true;
      defaultCacheTtl = minsToSecs 10;
      defaultCacheTtlSsh = minsToSecs 60;
      maxCacheTtl = hoursToSecs 1; # 1 hour
      maxCacheTtlSsh = hoursToSecs 4; # 1 hour
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
}
