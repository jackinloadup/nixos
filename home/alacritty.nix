{ config, lib, pkgs, ... }:

let
  settings = import ../settings;
  colorscheme = settings.colorscheme;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        size = 12;
      };

      background_opacity = 0.95;
      cursor.style = "Underline";

      colors = {
        # Default colors
        primary = {
          background = "0x${colorscheme.bg_0}";
          foreground = "0x${colorscheme.fg_1}";
        };

        # Normal colors
        normal = {
          black =   "0x${colorscheme.bg_1}";
          red =     "0x${colorscheme.red}";
          green =   "0x${colorscheme.green}";
          yellow =  "0x${colorscheme.yellow}";
          blue =    "0x${colorscheme.blue}";
          magenta = "0x${colorscheme.magenta}";
          cyan =    "0x${colorscheme.cyan}";
          white =   "0x${colorscheme.fg_0}";
        };

        # Bright colors
        bright = {
          black =   "0x${colorscheme.bg_2}";
          red =     "0x${colorscheme.br_red}";
          green =   "0x${colorscheme.br_green}";
          yellow =  "0x${colorscheme.br_yellow}";
          blue =    "0x${colorscheme.br_blue}";
          magenta = "0x${colorscheme.br_magenta}";
          cyan =    "0x${colorscheme.br_cyan}";
          white =   "0x${colorscheme.dim_0}";
        };
      };
    };
  };
}
