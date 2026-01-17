{ pkgs, lib, ... }:
{
  stylix = {
    enable = lib.mkDefault true;
    #image = lib.mkDefault "${pkgs.gnome-backgrounds}/share/backgrounds/gnome/symbolic-d.png";
    image = lib.mkDefault "${pkgs.budgie-backgrounds}/share/backgrounds/budgie/ocean-waves.jpg";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      monospace = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
    opacity = {
      terminal = 0.9;
      desktop = 1.0;
      popups = 1.0;
      applications = 0.95;
    };

    targets.plymouth.showLogo = false;
  };
}
