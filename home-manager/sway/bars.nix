{ config, pkgs, ... }:

with config.lib.base16.theme;
{
  bars = [
    {
      command = "${pkgs.waybar}/bin/waybar";
      position = "top";
      #fonts = fontConf;
      trayOutput = "*";
      colors = {
        background = "#${base00-hex}";
        statusline = "#${base04-hex}";
        separator = "#${base01-hex}";
        focusedWorkspace = {
          border = "#${base05-hex}";
          background = "#${base0D-hex}";
          text = "#${base00-hex}";
        };
        activeWorkspace = {
          border = "#${base05-hex}";
          background = "#${base03-hex}";
          text = "#${base00-hex}";
        };
        inactiveWorkspace = {
          border = "#${base03-hex}";
          background = "#${base01-hex}";
          text = "#${base05-hex}";
        };
        urgentWorkspace = {
          border = "#${base08-hex}";
          background = "#${base08-hex}";
          text = "#${base00-hex}";
        };
        bindingMode = {
          border = "#${base00-hex}";
          background = "#${base0A-hex}";
          text = "#${base00-hex}";
        };
      };
    }
  ];
}
