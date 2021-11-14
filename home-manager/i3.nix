{ config, pkgs, nixosConfig, lib, inputs, ... }:

{

  xsession.windowManager.i3 = {
    enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
    config = {
      terminal = "alacritty";
      modifier = "Mod4";
    };
  };

}
