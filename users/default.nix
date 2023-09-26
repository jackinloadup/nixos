# flake-parts module
{ self, config, ... }:
{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      lriutzel.imports = [ ./lriutzel ];
      kodi.imports = [ ./kodi ];
    };
  };
}
