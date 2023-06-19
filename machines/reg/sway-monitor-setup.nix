{
  self,
  inputs,
  pkgs,
  lib,
  ...
}: {
  home-manager.users.lriutzel.wayland.windowManager.sway.config = {
    output = {
      "DP-1" = {
        pos = "3840 0";
      };
      "DP-2" = {
        #transform = "90";
        pos = "0 0";
        bg = ''~/Pictures/background-virt.jpg fill'';
      };
    };

    workspaceOutputAssign = [
      {
        output = "DP-1";
        workspace = "1";
      }
    ];
  };
}
