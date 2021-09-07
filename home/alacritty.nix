{ config, lib, pkgs, ... }:

let
  settings = import ../settings;
  theme = settings.theme;
  font = theme.font;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      "live_config_reload" = true; # should work in next release
      font = {
        normal = {
          family = font.mono.family;
          style = font.mono.style;
        };
        size = font.size;
      };

      background_opacity = theme.background_opacity;
      cursor = with config.lib.base16.theme; {
        style = "Underline";
        text = "0x${base00-hex}";
        cursor = "0x${base05-hex}";
      };

      colors = with config.lib.base16.theme; {
        # Default colors
        primary = {
          background = "0x${base00-hex}";
          foreground = "0x${base05-hex}";
        };

        # Normal colors
        normal = {
          black =   "0x${base00-hex}";
          red =     "0x${base08-hex}";
          green =   "0x${base0B-hex}";
          yellow =  "0x${base0A-hex}";
          blue =    "0x${base0D-hex}";
          magenta = "0x${base0E-hex}";
          cyan =    "0x${base0C-hex}";
          white =   "0x${base05-hex}";
        };

        # Bright colors
        bright = {
          black =   "0x${base03-hex}";
          red =     "0x${base08-hex}";
          green =   "0x${base0B-hex}";
          yellow =  "0x${base0A-hex}";
          blue =    "0x${base0D-hex}";
          magenta = "0x${base0E-hex}";
          cyan =    "0x${base0C-hex}";
          white =   "0x${base07-hex}";
        };

        indexed_colors = [
          { index = 16; color = "0x${base09-hex}"; }
          { index = 17; color = "0x${base0F-hex}"; }
          { index = 18; color = "0x${base01-hex}"; }
          { index = 19; color = "0x${base02-hex}"; }
          { index = 20; color = "0x${base04-hex}"; }
          { index = 21; color = "0x${base06-hex}"; }
        ];
      };
    };
  };
}
