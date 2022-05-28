{ self, inputs, pkgs, lib, ... }:

with lib;
{
  imports = [
    ../../home-manager/foot.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null; # don't override system-installed one
    wrapperFeatures.gtk = true;
    config = {
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      modifier = "Mod4";
      terminal = "${pkgs.foot}/bin/footclient";
      
      input = import ../../home-manager/sway/input.nix;
      startup = [
        {
          command = "${pkgs.kodi-wayland}/bin/kodi";
        }
      ];
    };
  };
}
