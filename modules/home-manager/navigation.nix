{ lib
, config
, ...
}:

let
  inherit (lib) mkDefault;
  swayConfig = config.wayland.windowManager.sway.config;

  # Vim keys
  left = "h";
  down = "j";
  up = "k";
  right = "l";

  modifier = "Mod4";

  keybindings =
    let # Sway and I3 common keybindings
      inherit (swayConfig) left down up right modifier;
      mod = modifier;
    in
    {
      ## Focus
      # Vim keys
      "${mod}+${left}" = "focus left";
      "${mod}+${down}" = "focus down";
      "${mod}+${up}" = "focus up";
      "${mod}+${right}" = "focus right";

      # Arrow Keys
      "${mod}+Left" = "focus left";
      "${mod}+Down" = "focus down";
      "${mod}+Up" = "focus up";
      "${mod}+Right" = "focus right";

      ## Move Window
      "${mod}+Shift+${left}" = "move left";
      "${mod}+Shift+${down}" = "move down";
      "${mod}+Shift+${up}" = "move up";
      "${mod}+Shift+${right}" = "move right";

      ## Move Workspace
      "${mod}+Shift+Left" = "move workspace to output left";
      "${mod}+Shift+Up" = "move workspace to output up";
      "${mod}+Shift+Down" = "move workspace to output down";
      "${mod}+Shift+Right" = "move workspace to output right";

      ## Focus Workspace
      "${mod}+1" = "workspace number 1";
      "${mod}+2" = "workspace number 2";
      "${mod}+3" = "workspace number 3";
      "${mod}+4" = "workspace number 4";
      "${mod}+5" = "workspace number 5";
      "${mod}+6" = "workspace number 6";
      "${mod}+7" = "workspace number 7";
      "${mod}+8" = "workspace number 8";
      "${mod}+9" = "workspace number 9";
      "${mod}+0" = "workspace number 10";

      ## Move Container to Workspace
      "${mod}+Shift+1" = "move container to workspace number 1";
      "${mod}+Shift+2" = "move container to workspace number 2";
      "${mod}+Shift+3" = "move container to workspace number 3";
      "${mod}+Shift+4" = "move container to workspace number 4";
      "${mod}+Shift+5" = "move container to workspace number 5";
      "${mod}+Shift+6" = "move container to workspace number 6";
      "${mod}+Shift+7" = "move container to workspace number 7";
      "${mod}+Shift+8" = "move container to workspace number 8";
      "${mod}+Shift+9" = "move container to workspace number 9";
      "${mod}+Shift+0" = "move container to workspace number 10";
    };
in
{
  config = {
    wayland.windowManager.sway = {
      config = {
        inherit left down up right modifier keybindings;
      };
    };
    xsession.windowManager.i3 = {
      #inherit left down up right;
      config = {
        inherit modifier keybindings;
      };
    };
    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";
      bind = [
        # move focus with arrows
        "$mod, left, hy3:movefocus, l"
        "$mod, right, hy3:movefocus, r"
        "$mod, up, hy3:movefocus, u"
        "$mod, down, hy3:movefocus, d"

        # hy3:move focus with vim keys
        "$mod, ${left}, hy3:movefocus, l"
        "$mod, ${right}, hy3:movefocus, r"
        "$mod, ${up}, hy3:movefocus, u"
        "$mod, ${down}, hy3:movefocus, d"

        # hy3:move window with vim keys
        "$mod SHIFT, ${left}, hy3:movewindow, l, once"
        "$mod SHIFT, ${right}, hy3:movewindow, r, once"
        "$mod SHIFT, ${up}, hy3:movewindow, u, once"
        "$mod SHIFT, ${down}, hy3:movewindow, d, once"
        "$mod SHIFT, left, hy3:movewindow, l, once"
        "$mod SHIFT, right, hy3:movewindow, r, once"
        "$mod SHIFT, up, hy3:movewindow, u, once"
        "$mod SHIFT, down, hy3:movewindow, d, once"



        "$mod+CONTROL+SHIFT, h, hy3:movewindow, l, once, visible"
        "$mod+CONTROL+SHIFT, j, hy3:movewindow, d, once, visible"
        "$mod+CONTROL+SHIFT, k, hy3:movewindow, u, once, visible"
        "$mod+CONTROL+SHIFT, l, hy3:movewindow, r, once, visible"
        "$mod+CONTROL+SHIFT, left, hy3:movewindow, l, once, visible"
        "$mod+CONTROL+SHIFT, down, hy3:movewindow, d, once, visible"
        "$mod+CONTROL+SHIFT, up, hy3:movewindow, u, once, visible"
        "$mod+CONTROL+SHIFT, right, hy3:movewindow, r, once, visible"

        #switch workspaces with mod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        #"$mod, 1, workspace, 01"
        #"$mod, 2, workspace, 02"
        #"$mod, 3, workspace, 03"
        #"$mod, 4, workspace, 04"
        #"$mod, 5, workspace, 05"
        #"$mod, 6, workspace, 06"
        #"$mod, 7, workspace, 07"
        #"$mod, 8, workspace, 08"
        #"$mod, 9, workspace, 09"
        "$mod, F1, workspace, 11"
        "$mod, F2, workspace, 12"
        "$mod, F3, workspace, 13"
        "$mod, F4, workspace, 14"
        "$mod, F5, workspace, 15"
        "$mod, F6, workspace, 16"
        "$mod, F7, workspace, 17"
        "$mod, F8, workspace, 18"
        "$mod, F9, workspace, 19"
        "$mod, F10, workspace, 20"

        # Move active window to a workspace with mod + SHIFT + [0-9]
        "$mod+SHIFT, 1, hy3:movetoworkspace, 01"
        "$mod+SHIFT, 2, hy3:movetoworkspace, 02"
        "$mod+SHIFT, 3, hy3:movetoworkspace, 03"
        "$mod+SHIFT, 4, hy3:movetoworkspace, 04"
        "$mod+SHIFT, 5, hy3:movetoworkspace, 05"
        "$mod+SHIFT, 6, hy3:movetoworkspace, 06"
        "$mod+SHIFT, 7, hy3:movetoworkspace, 07"
        "$mod+SHIFT, 8, hy3:movetoworkspace, 08"
        "$mod+SHIFT, 9, hy3:movetoworkspace, 09"
        "$mod+SHIFT, 0, hy3:movetoworkspace, 10"
        "$mod+SHIFT, F1, hy3:movetoworkspace, 11"
        "$mod+SHIFT, F2, hy3:movetoworkspace, 12"
        "$mod+SHIFT, F3, hy3:movetoworkspace, 13"
        "$mod+SHIFT, F4, hy3:movetoworkspace, 14"
        "$mod+SHIFT, F5, hy3:movetoworkspace, 15"
        "$mod+SHIFT, F6, hy3:movetoworkspace, 16"
        "$mod+SHIFT, F7, hy3:movetoworkspace, 17"
        "$mod+SHIFT, F8, hy3:movetoworkspace, 18"
        "$mod+SHIFT, F9, hy3:movetoworkspace, 19"
        "$mod+SHIFT, F10, hy3:movetoworkspace, 20"

        #"$mod SHIFT, 1, hy3:movetoworkspace, 1"
        #"$mod SHIFT, 2, hy3:movetoworkspace, 2"
        #"$mod SHIFT, 3, hy3:movetoworkspace, 3"
        #"$mod SHIFT, 4, hy3:movetoworkspace, 4"
        #"$mod SHIFT, 5, hy3:movetoworkspace, 5"
        #"$mod SHIFT, 6, hy3:movetoworkspace, 6"
        #"$mod SHIFT, 7, hy3:movetoworkspace, 7"
        #"$mod SHIFT, 8, hy3:movetoworkspace, 8"
        #"$mod SHIFT, 9, hy3:movetoworkspace, 9"
        #"$mod SHIFT, 0, hy3:movetoworkspace, 10"

        "$mod+CONTROL, 1, hy3:focustab, index, 01"
        "$mod+CONTROL, 2, hy3:focustab, index, 02"
        "$mod+CONTROL, 3, hy3:focustab, index, 03"
        "$mod+CONTROL, 4, hy3:focustab, index, 04"
        "$mod+CONTROL, 5, hy3:focustab, index, 05"
        "$mod+CONTROL, 6, hy3:focustab, index, 06"
        "$mod+CONTROL, 7, hy3:focustab, index, 07"
        "$mod+CONTROL, 8, hy3:focustab, index, 08"
        "$mod+CONTROL, 9, hy3:focustab, index, 09"
        "$mod+CONTROL, 0, hy3:focustab, index, 10"
      ];
    };
  };

}
