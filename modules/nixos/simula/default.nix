{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  settings = import ../../../settings;
in {
  options.programs.simula.enable = mkEnableOption "Enable Simula VR platform";

  config = mkIf config.programs.simula.enable {
    environment.systemPackages = [pkgs.monado];
  };
}
