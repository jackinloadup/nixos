{
  self,
  inputs,
  pkgs,
  lib,
  ...
}: {
  # set logitec mouse to autosuspend after 60 seconds
  services.udev.extraRules = ''
    # Logitech Unifying Receiver
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="120000"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52f", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="120000"
  '';
}
