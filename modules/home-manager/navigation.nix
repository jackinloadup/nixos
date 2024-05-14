{
  lib,
  config,
  ...
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

  keybindings = let # Sway and I3 common keybindings
    inherit (swayConfig) left down up right modifier;
    mod = modifier;
  in {
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
in {
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
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # move focus with vim keys
        "$mod, ${left}, movefocus, l"
        "$mod, ${right}, movefocus, r"
        "$mod, ${up}, movefocus, u"
        "$mod, ${down}, movefocus, d"

        # move window with vim keys
        "$mod SHIFT, ${left}, movewindow, l"
        "$mod SHIFT, ${right}, movewindow, r"
        "$mod SHIFT, ${up}, movewindow, u"
        "$mod SHIFT, ${down}, movewindow, d"

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
        # Move active window to a workspace with mod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
      ];
    };
  };

}
