{
  lib,
  config,
  ...
}: {
  imports = [
    ../../modules/home-manager/zoom.nix
  ];

  config = {
    programs.zoom-us.enable = true;
  };
}
