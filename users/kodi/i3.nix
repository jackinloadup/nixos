{
  self,
  inputs,
  pkgs,
  lib,
  ...
}: let
  kodiSplash = "${pkgs.kodi}/share/kodi/media/splash.jpg";
in {
  imports = [
    ../../home-manager/i3.nix
  ];

  programs.bash = {
    enable = true;
    profileExtra = ''
      if shopt -q login_shell; then
          [[ -f ~/.bashrc ]] && source ~/.bashrc
          [[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]] && exec startx
      else
          exit 1 # Somehow this is a non-bash or non-login shell.
      fi
    '';
  };

  xsession.windowManager.i3.config = {
    bars = [];
    startup = [
      {
        command = "{pkgs.feh}/bin/feh --bg-scale ${kodiSplash}";
        notification = false;
      }
      {command = "${pkgs.kodi}/bin/kodi";}
    ];
  };
}
