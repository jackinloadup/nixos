{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hardware.solo2;
in
{
  # TODO: upstream to nixpkgs
  options.hardware.solo2.enable = mkEnableOption "Enable udev rules for Solo2 seciruty key";

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.solo2-cli ];

    services.udev.extraRules = ''
      # NXP LPC55 ROM bootloader (unmodified)
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="0021", TAG+="uaccess"
      # NXP LPC55 ROM bootloader (with Solo 2 VID:PID)
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="b000", TAG+="uaccess"
      # Solo 2
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="beee", TAG+="uaccess"
      # Solo 2
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="beee", TAG+="uaccess"
      #KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"
    '';
  };
}
