{
  config,
  lib,
  pkgs,
  nixosConfig,
  ...
}: let
  inherit (lib) mkIf;
  settings = import ../../settings;
  theme = settings.theme;
  font = theme.font;
  swayEnabled = config.wayland.windowManager.sway.enable;
in {
  imports = [
    ./base16.nix
  ];

  config = mkIf config.programs.foot.enable {
    #home.shellAliases = {
    #  ssh = "TERM=xterm-265color ssh";
    #};

    systemd.user.services.foot = mkIf swayEnabled {
      Unit.BindsTo = "sway-session.target";
      Install.WantedBy = ["sway-session.target"];
    };

    programs.foot = {
      #enable = nixosConfig.programs.sway.enable;
      #server.enable = nixosConfig.programs.sway.enable;
      settings = {
        main = {
          term = "xterm-256color";

          font = "monospace:size=${toString (settings.theme.font.size - 4)}";
          dpi-aware = true;
        };

        #scrollback = {
        #  lines=1000;
        #  multiplier=3.0;
        #  indicator-position=relative;
        #  indicator-format="<";
        #};

        colors = with config.lib.base16.theme; {
          alpha = settings.theme.background_opacity;
          foreground = base05-hex;
          background = base00-hex;
          regular0 = base00-hex;
          regular1 = base08-hex;
          regular2 = base0B-hex;
          regular3 = base0A-hex;
          regular4 = base0D-hex;
          regular5 = base0E-hex;
          regular6 = base0C-hex;
          regular7 = base05-hex;
          bright0 = base03-hex;
          bright1 = base08-hex;
          bright2 = base0B-hex;
          bright3 = base0A-hex;
          bright4 = base0D-hex;
          bright5 = base0E-hex;
          bright6 = base0C-hex;
          bright7 = base07-hex;
        };
        key-bindings = {
          font-increase = "Control+plus Control+equal Control+KP_Add";
          font-decrease = "Control+minus Control+KP_Subtract";
        };
      };
    };
  };
}
