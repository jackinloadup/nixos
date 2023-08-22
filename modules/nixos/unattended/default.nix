{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce mkEnableOption;
in {
  options.boot.unattended = mkEnableOption "Optimise for an unattended machine";

  config = mkIf config.boot.unattended {
    machine.kernel = {
      rebootAfterPanic = mkForce 10;
      panicOnOOM = mkForce true;
      panicOnHungTaskTimeout = mkForce 1;
    };
  };
}
