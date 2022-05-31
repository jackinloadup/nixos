{ lib, pkgs, config, ... }:
with lib;
{
  options.hardware.yubikey.enable = mkEnableOption "Add resources to support using a Yubico Yubikey";

  config = mkIf config.hardware.yubikey.enable {
    environment.systemPackages = with pkgs; [
      # cli
      yubikey-manager
      yubikey-personalization

      # gui
      yubikey-manager-qt
      yubikey-personalization-gui
    ];

    services.udev.extraRules = ''
ACTION!="add|change", GOTO="yubico_end"

# Udev rules for letting the console user access the Yubikey USB
# device node, needed for challenge/response to work correctly.

# Yubico Yubikey II
ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", \
    ENV{ID_SECURITY_TOKEN}="1"

LABEL="yubico_end"
    '';

    # smartcard daemon
    services.pcscd.enable = true;
  };
}
