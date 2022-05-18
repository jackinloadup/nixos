{ config, pkgs, ... }:

with config.lib.base16.theme;
{
  colors = {
    background = "#${base00-hex}";
    focused = {
      border = "#${base05-hex}";
      background = "#${base0D-hex}";
      text = "#${base00-hex}";
      indicator = "#${base0B-hex}";
      childBorder = "#${base0D-hex}";
    };
    focusedInactive = {
      border = "#${base03-hex}";
      background = "#${base01-hex}";
      text = "#${base05-hex}";
      indicator = "#${base03-hex}";
      childBorder = "#${base01-hex}";
    };
    unfocused = {
      border = "#${base03-hex}";
      background = "#${base01-hex}";
      text = "#${base05-hex}";
      indicator = "#${base0B-hex}";
      childBorder = "#${base01-hex}";
    };
    urgent = {
      border = "#${base08-hex}";
      background = "#${base08-hex}";
      text = "#${base00-hex}";
      indicator = "#${base08-hex}";
      childBorder = "#${base08-hex}";
    };
  };
}
