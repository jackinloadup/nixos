{ flake
, lib
, config
, ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [
    flake.inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];
  config = mkIf config.services.flatpak.enable {
    services.flatpak.update.auto = {
      enable = true;
      onCalendar = "weekly"; # Default value
    };
    services.flatpak.packages = [
      #"com.discordapp.Discord"
    ];
  };
}
