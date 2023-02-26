{ lib, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
in {
  options.machine.vpn.enable = mkEnableOption "Enable VPN";
  options.machine.vpn.isLighthouse = mkEnableOption "Node is a lighthouse";

  config = mkIf config.machine.vpn {
    services.nebula.networks = {

    };
  };
}
