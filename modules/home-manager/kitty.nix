{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf;
in {
  config = {
    programs.kitty = {
      settings = {
        #background_opacity = "0.8";
      };
    };
  };
}
