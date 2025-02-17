
{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
inherit (lib) mkDefault mkIf;
in {
  config = {
    environment.systemPackages = [
        pkgs.wev
        pkgs.wdisplays
        pkgs.wlr-randr
    ];

  };
}
