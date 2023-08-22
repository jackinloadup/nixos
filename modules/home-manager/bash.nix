
{
  config,
  pkgs,
  nixosConfig,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf config.programs.bash.enable {
    programs.nix-index.enableBashIntegration = true;
  };
}
