{ config
, lib
, ...
}:
let
  inherit (lib) mkIf;
  swayEnabled = config.wayland.windowManager.sway.enable;
in
{
  config = mkIf config.programs.foot.enable {
    systemd.user.services.foot = mkIf swayEnabled {
      Unit.BindsTo = "sway-session.target";
      Install.WantedBy = [ "sway-session.target" ];
    };

    programs.foot = {
      #enable = nixosConfig.programs.sway.enable;
      #server.enable = nixosConfig.programs.sway.enable;
      settings = {
        main = {
          term = "xterm-256color";
        };

        #scrollback = {
        #  lines=1000;
        #  multiplier=3.0;
        #  indicator-position=relative;
        #  indicator-format="<";
        #};

        key-bindings = {
          font-increase = "Control+plus Control+equal Control+KP_Add";
          font-decrease = "Control+minus Control+KP_Subtract";
        };
      };
    };
  };
}
