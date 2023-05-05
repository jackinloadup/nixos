{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption types attrNames genAttrs;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  config = mkIf config.hardware.rtl-sdr.enable {
    users.users = addExtraGroups normalUsers ["plugdev"];

    environment.systemPackages = with pkgs; [
      cubicsdr
      gnuradio # there is a minimal version
      sdrangel
      nrsc5
      gqrx
    ];
  };
}
