{ config, pkgs, nixosConfig, lib, inputs, ... }:

let
  settings = import ../settings;
in {
  imports = [];

  config = {
    # Display desktop notfications.
    services.dunst = lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) {
      enable = true;

      #iconTheme = {
      #  package = pkgs.gnome.adwaita-icon-theme;
      #  name = "Adwaita";
      #};

      settings = {
        global = with settings.theme; {
          follow = "keyboard"; # Show notifications where the keyboard has foucs.
          font = "${font.normal.family} ${font.normal.style} ${toString(font.size)}";
          word_wrap = "yes";
          format = "<b>%s</b>\\n%b";
          frame_width = borderWidth; # Border size.
          geometry = "400x5-18+42"; # Size & location of notifications.
          markup = "full"; # Enable basic markup in messages.
          show_age_threshold = settings.timeouts.show_age_after;
          icon_position = "left";
          max_icon_size = 32; # Put a limit on image/icon size.
          padding = 6; # Vertical padding
          horizontal_padding = 6;
          separator_color = "frame"; # Match to the frame color.
          separator_height = borderWidth; # Space between notifications.
          sort = "yes"; # Sort messages by urgency.
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = true;
          history_lengh = 30;
          sticky-history = "yes";
          dmenu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --term=alacritty --dmenu='bemenu -i -l 10'";
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
        };

        # @TODO these shortcuts should be using super not ctrl as they are workspace level commands
        shortcuts = {
          close = "ctrl+space";
          close_all = "ctrl+shift+space";
          history = "ctrl+grave";
          context = "ctrl+shift+period";
        };

        urgency_low = with config.lib.base16.theme; {
          background ="#${base00-hex}";
          foreground ="#${base04-hex}";
          frame_color ="#${base03-hex}";
          timeout = "15s";
        };

        urgency_normal = with config.lib.base16.theme; {
          background ="#${base00-hex}";
          foreground ="#${base04-hex}";
          frame_color ="#${base0A-hex}";
          timeout = "30s";
        };

        urgency_critical = with config.lib.base16.theme; {
          background ="#${base00-hex}";
          foreground ="#${base04-hex}";
          frame_color ="#${base0B-hex}";
          timeout = "1d";
        };
      };
    };
  };
}
