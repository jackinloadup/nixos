{
  self,
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  swayConfig = config.wayland.windowManager.sway.config;
  kodiSplash = "${pkgs.kodi-wayland}/share/kodi/media/splash.jpg";
in {
  imports = [
  ];

  config = {
    programs.kodi = {
      enable = true;
      package = pkgs.kodi-wayland;
      #addonSettings = {
      #  "service.xbmc.versioncheck".versioncheck_enable = "false";
      #};
      #sources = let
      #  rootPath = "/mnt/gumdrop/media/";
      #  buildSource = name: path: {
      #    name = name;
      #    path = rootPath + path;
      #    allowsharing = "true";
      #  };
      #in {
      #  video = {
      #    default = "Movies";
      #    source = [
      #      buildSource "Movies" "Movies/"
      #      buildSource "TV" "TV/"
      #    ];
      #  };
      #  music = {
      #    default = "Music";
      #    source = [
      #      buildSource "Lossless" "Music/Lossless"
      #      buildSource "Lossy" "Music/Lossy"
      #      buildSource "Linux" "Music/Linux"
      #    ];
      #  };
      #};
      #settings = {
      #  cache = {
      #    buffermode = 1; # buffer all filesystems
      #    #memorysize = ; #
      #    readfactor = 4.0; # determines the max readrate in terms of readfactor * avg bitrate of a video file
      #  };
      #  seeksteps = "15, 30, 30, 60, 60, 300";
      #};
    };

    systemd.user.services.kodi = {
      enable = true;
      description = "Kodi Media Center.";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${config.programs.kodi.package}/bin/kodi --lircdev /run/lirc/lircd 
                  --standalone & waitPID=$!
        '';
        WorkingDirectory = config.users.users.kodi.home;
        Restart = "always";
        PrivateTmp = "true";
        NoNewPrivileges = "true";
      };
      #wantedBy = [ "default.target" ];

      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
     };
  };
}
