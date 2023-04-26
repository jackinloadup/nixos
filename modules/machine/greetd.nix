{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkOption types getBin getExe;
  desktops = config.services.xserver.displayManager.sessionData.desktops;
  sessions = "${desktops}/share/wayland-sessions:${desktops}/share/xsessions";
in {
  imports = [ ];

  options.machine.displayManager = mkOption {
    type = with types; nullOr (enum [ "greetd" ]);
  };

  config = mkIf (config.machine.displayManager == "greetd") {
    # keep systemd startup logs on tty1
    boot.kernelParams = [ "console=tty1" ];

    #environment.etc."greetd/environments".text = ''
    #  ${lib.optionalString config.programs.sway.enable "${getBin pkgs.systemd}/bin/systemd-cat -t sway ${getExe pkgs.sway}"}
    #  ${lib.optionalString config.services.xserver.windowManager.i3.enable "${getBin pkgs.systemd}/bin/systemd-cat -t i3 ${getBin pkgs.xorg.xinit}/bin/startx ~/.xsession"}
    #  ${lib.optionalString config.services.xserver.desktopManager.gnome.enable "${getBin pkgs.systemd}/bin/systemd-cat -t gnome gnome-session"}
    #'';

    users.users.greeter.group = "greeter";
    users.groups.greeter = { };

    services.greetd =
      let
        theme = "${pkgs.ayu-theme-gtk}/share/themes/Ayu-Dark/gtk-3.0/gtk.css";
        greetdSwayCfg = pkgs.writeText "sway-config" ''
          exec "${getBin pkgs.greetd.gtkgreet}/bin/gtkgreet -s ${theme} -l; ${getBin pkgs.sway}/bin/swaymsg exit"

          bindsym Mod4+shift+e exec ${pkgs.sway}/bin/swaynag \
          -t warning \
          -m 'What do you want to do?' \
          -b 'Poweroff' 'systemctl poweroff' \
          -b 'Reboot' 'systemctl reboot'

          exec ${getBin pkgs.systemd}/bin/systemctl --user import-environment
          include /etc/sway/config.d/*
        '';
      in
      {
        enable = true;
        vt = 7; # use tty7 to stay away from systemd startup logs
        settings = {
          default_session = {
            command = "${getExe pkgs.sway} --config ${greetdSwayCfg}";
            #command = "${lib.makeBinPath [pkgs.greetd.tuigreet] }/tuigreet -i --sessions ${sessions} --time ";
            user = "greeter";
          };
          initial_session = {
            command = config.services.xserver.displayManager.defaultSession;
            user = config.services.xserver.displayManager.autoLogin.user;
          };
        };
      };
  };
}
