{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf getBin getExe optionals;
  termCmd = "${getBin pkgs.foot}/bin/footclient --client-environment";
  left = "h";
  down = "j";
  up = "k";
  right = "l";
in {
  config = let
    menu = "${getExe pkgs.j4-dmenu-desktop} --no-generic --term='${termCmd}' --dmenu='${getExe pkgs.bemenu} --ignorecase --list 10 --center --border-radius 12 --width-factor \"0.2\" --border 2 --margin 20 --fixed-height --prompt \"\" --prefix \">\" --line-height 20 --ch 15'";
  in {
    wayland.windowManager.hyprland.settings = {
      #plugins = [ pkgs.hyprlandPlugins.hy3 ];

      animations = {
        enabled = true;
        # Selmer443 config
        bezier = [
          "pace,0.46, 1, 0.29, 0.99"
          "overshot,0.13,0.99,0.29,1.1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
        ];
        animation = [
          "windowsIn,1,6,md3_decel,slide"
          "windowsOut,1,6,md3_decel,slide"
          "windowsMove,1,6,md3_decel,slide"
          "fade,1,10,md3_decel"
          "workspaces,1,9,md3_decel,slide"
          "workspaces, 1, 6, default"
          "specialWorkspace,1,8,md3_decel,slide"
          "border,1,10,md3_decel"
        ];
      };

      #"$mod" = "SUPER";
      "$terminal" = "${pkgs.foot}/bin/foot";
      bind = [
        "$mod, Return, exec, ${pkgs.foot}/bin/foot"
        "$mod SHIFT, q, killactive"
        "$mod, Space, exec, ${menu}"
        "$mod SHIFT, Space, togglefloating"
        "$mod, f, fullscreen"

        # idk why this isn't working
        "$mod SHIFT, code:61, togglesplit,"
        "$mod SHIFT, I, togglegroup"
        "$mod, /, togglesplit,"
        "$mod,code:61,togglesplit,"
        "$mod,x,togglesplit,"

        ## move focus with arrows
        #"$mod, left, movefocus, l"
        #"$mod, right, movefocus, r"
        #"$mod, up, movefocus, u"
        #"$mod, down, movefocus, d"

        ## move focus with vim keys
        #"$mod, ${left}, movefocus, l"
        #"$mod, ${right}, movefocus, r"
        #"$mod, ${up}, movefocus, u"
        #"$mod, ${down}, movefocus, d"

        ## move window with vim keys
        #"$mod SHIFT, ${left}, movewindow, l"
        #"$mod SHIFT, ${right}, movewindow, r"
        #"$mod SHIFT, ${up}, movewindow, u"
        #"$mod SHIFT, ${down}, movewindow, d"

        ##switch workspaces with mod + [0-9]
        #"$mod, 1, workspace, 1"
        #"$mod, 2, workspace, 2"
        #"$mod, 3, workspace, 3"
        #"$mod, 4, workspace, 4"
        #"$mod, 5, workspace, 5"
        #"$mod, 6, workspace, 6"
        #"$mod, 7, workspace, 7"
        #"$mod, 8, workspace, 8"
        #"$mod, 9, workspace, 9"
        #"$mod, 0, workspace, 10"
        ## Move active window to a workspace with mod + SHIFT + [0-9]
        #"$mod SHIFT, 1, movetoworkspace, 1"
        #"$mod SHIFT, 2, movetoworkspace, 2"
        #"$mod SHIFT, 3, movetoworkspace, 3"
        #"$mod SHIFT, 4, movetoworkspace, 4"
        #"$mod SHIFT, 5, movetoworkspace, 5"
        #"$mod SHIFT, 6, movetoworkspace, 6"
        #"$mod SHIFT, 7, movetoworkspace, 7"
        #"$mod SHIFT, 8, movetoworkspace, 8"
        #"$mod SHIFT, 9, movetoworkspace, 9"
        #"$mod SHIFT, 0, movetoworkspace, 10"

      ];

      bindm = [ # Mouse binds
        # "SUPER,mouse_down,workspace,e+1"
        # "SUPER,mouse_up,workspace,e-1"
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];
    };
  };
}
