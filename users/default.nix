# flake-parts module
{ self, config, inputs, ... }:
{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      lriutzel.imports = [ inputs.self.nixosModules.lriutzelFull ];
      lriutzelFull.imports = [
        ./lriutzel/default.nix
        ./lriutzel/full.nix
        inputs.self.nixosModules.lriutzelGui
      ];
      lriutzelGui.imports = [
        ./lriutzel/gui.nix
        inputs.self.nixosModules.lriutzelTui
      ];
      lriutzelTui.imports = [ ./lriutzel/tui.nix ];
      criutzel.imports = [ ./criutzel ];
      kodi.imports = [ ./kodi ];
    };
  };
}
