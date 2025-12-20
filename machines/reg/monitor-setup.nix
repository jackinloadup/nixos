{ ...
}: {
  home-manager.sharedModules = [
    {
      wayland.windowManager = {
        hyprland.settings = {
          monitor = [
            "DP-8, highres, auto, 1"
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
  #services.udev.extraRules = ''
  #  #ACTION=="add", ATTRS{idVendor}=="2109", ATTRS{idProduct}=="0820", ENV{XAUTHORITY}="/home/lriutzel/.Xauthority", ENV{DISPLAY}=":0", OWNER="lriutzel", RUN+="/usr/local/bin/usb-<yourdevice>-in_udev"
  #  #ACTION=="remove", ATTRS{idVendor}=="2109", ATTRS{idProduct}=="0820", ENV{XAUTHORITY}="/home/lriutzel/.Xauthority", ENV{DISPLAY}=":0", OWNER="lriutzel", RUN+="/usr/local/bin/usb-<yourdevice>-out_udev"
  #  # switch monitor inputs when hub is connected.
  #  # switch to mac when removed and switch to this computer when added
  #  ACTION=="add", ATTRS{idVendor}=="2109", ATTRS{idProduct}=="0820", RUN+="/usr/local/bin/usb-<yourdevice>-in_udev"
  #  ACTION=="remove", ATTRS{idVendor}=="2109", ATTRS{idProduct}=="0820", RUN+="/usr/local/bin/usb-<yourdevice>-out_udev"
  #'';
}
