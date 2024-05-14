{
  ...
}: {
  home-manager.sharedModules = [
    {
      wayland.windowManager ={
        hyprland.settings = {
          monitor = [
            "DP-5, highres, auto, 1"
          ];
        };
        sway.config = {
          output = {
            "DP-1" = {
              # 2k 32in
              pos = "3840 0";
            };
            "DP-5" = {
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
}
