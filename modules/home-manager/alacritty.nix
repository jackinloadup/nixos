{ config
, lib
, pkgs
, nixosConfig
, ...
}:
let
  settings = import ../../settings;
  theme = settings.theme;
  font = theme.font;
in
{
  config = {
    programs.alacritty = {
      settings = {
        "live_config_reload" = true; # should work in next release

        font = {
          size = font.size;
        };

        cursor = {
          style = "Underline";
        };

        hints = {
          enabled = [
            {
              regex = "([0-9a-f]{12,128})|([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3})";
              action = "Copy";
              post_processing = false;
              binding = {
                key = "U";
                mods = "Control|Shift";
              };
            }
          ];
        };
      };
    };
  };
}
