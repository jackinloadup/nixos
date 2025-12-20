{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.hardware.yubikey.enable = mkEnableOption "Add resources to support using a Yubico Yubikey";

  config = mkIf config.hardware.yubikey.enable {
    environment.systemPackages = [
      # cli
      pkgs.yubikey-manager
      pkgs.yubikey-personalization

      # gui
      #pkgs.yubikey-manager-qt # end of life upstream
      #pkgs.yubikey-personalization-gui # end of life upstream
      pkgs.yubioath-flutter
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
