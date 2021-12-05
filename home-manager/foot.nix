{ config, lib, pkgs, nixosConfig, ... }:

let
  settings = import ../settings;
  theme = settings.theme;
  font = theme.font;
in
{
  #home.shellAliases = {
  #  ssh = "TERM=xterm-265color ssh";
  #};

  programs.foot = {
    enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        font = "monospace:pixelsize=${toString settings.theme.font.size}";
        dpi-aware = false;
      };

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
    };
  };
}
