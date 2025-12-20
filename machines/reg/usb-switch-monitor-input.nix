# Change monitor input based on hub being connected to computer
{ ... }:
{
  config = {

    #services.udev.extraRules = ''
    #  # Bus 003 Device 071: ID 1a40:0101 Terminus Technology Inc. Hub
    #  ACTION=="add", ATTRS{idVendor}=="1a40", ATTRS{idProduct}=="0101", ENV{XAUTHORITY}="/home/<user>/.Xauthority", ENV{DISPLAY}=":0", OWNER="<user>", RUN+="/usr/local/bin/usb-<yourdevice>-in_udev"
    #  ACTION=="remove", ATTRS{idVendor}=="1a40", ATTRS{idProduct}=="0101", ENV{XAUTHORITY}="/home/<user>/.Xauthority", ENV{DISPLAY}=":0", OWNER="<user>", RUN+="/usr/local/bin/usb-<yourdevice>-out_udev"
    #ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="120000"
    #'';
  };
}
