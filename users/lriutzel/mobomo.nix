{ lib, config, nixosConfig, ... }:

let
  cfg = nixosConfig.machine;
  ifTui = if (cfg.sizeTarget > 0) then true else false;
  ifGraphical = if (cfg.sizeTarget > 1) then true else false;
in {
  imports = [
    ../../home-manager/zoom.nix
  ];

  config = {
    programs.zoom-us.enable = ifGraphical;
  };
}
