{ lib, pkgs, config, ... }:
with lib;
{
  options.yubikey = mkEnableOption "Add resources to support using a Yubico Yubikey";

  config = mkIf config.yubikey {
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
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

    services.pcscd.enable = true;
  };
}
