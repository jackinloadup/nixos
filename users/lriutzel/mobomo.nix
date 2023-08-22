{
  lib,
  config,
  nixosConfig,
  ...
}: let
  cfg = nixosConfig.machine;
  ifTui = cfg.sizeTarget > 0;
  ifGraphical = cfg.sizeTarget > 1;
in {
  imports = [
    ../../modules/home-manager/zoom.nix
  ];

  config = {
    programs.zoom-us.enable = ifGraphical;
  };
}
