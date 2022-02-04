{ self, inputs, pkgs, lib, ... }:

{
  home-manager.users.lriutzel.wayland.windowManager.sway.config = {
    output = {
      "DP-1" = {
        pos = "1440 500";
      };
      "DP-2" = {
        transform = "270";
        pos = "0 0";
        bg = ''~/background-virt.jpg fill'';
      };
    };

    workspaceOutputAssign = [
      { output = "DP-1"; workspace = "1"; }
    ];
  };

}
