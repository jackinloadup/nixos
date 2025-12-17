{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.programs.kitty;

in mkIf cfg.enable {
  config = {
    programs.kitty = {
      settings = {
        background_opacity = 0.8;
      };
    };
  };
}
