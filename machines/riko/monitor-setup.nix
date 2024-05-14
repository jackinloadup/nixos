{
  ...
}: {
  config = {
    home-manager.sharedModules = [
      {
        wayland.windowManager = {
          hyprland.settings = {
            monitor = [
              "eDP-1, highres, auto, 1"
            ];
          };
          sway.config = {
            output = {
              "eDP-1" = {
                # 4k 42in
                #transform = "90";
                pos = "0 0";
                #bg = ''~/Pictures/background-virt.jpg fill'';
              };
            };

            #workspaceOutputAssign = [
            #  {
            #    output = "DP-1";
            #    workspace = "1";
            #  }
            #];
          };
        };
      }
    ];
  };
}

