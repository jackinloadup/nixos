{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption getBin getExe optionalString types literalExpression;
  cfg = config.boot.initrd.network.tor;
in {
  imports = [
    ./tor.nix
    ./ntp.nix
    ./havaged.nix
  ];
}
