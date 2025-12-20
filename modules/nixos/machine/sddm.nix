{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.displayManager.sddm.enable {
    services.xserver.enable = true;
    programs.xwayland.enable = true;
    #services.xserver.autorun = true;
    services.xserver.displayManager.lightdm.enable = false;
    environment.systemPackages = [ pkgs.catppuccin-sddm-corners ];
    services.displayManager.sddm = {
      theme = "catppuccin-sddm-corners";
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
  };
}
