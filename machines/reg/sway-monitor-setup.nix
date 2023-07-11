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
        # 2k 32in
        pos = "3840 0";
      };
      "DP-2" = {
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
}
