# flake-parts module
{ self, config, inputs, ... }:
let
  # Define modules in let-block to avoid self-reference
  lriutzelTuiModule.imports = [ ./lriutzel/tui.nix ];
  lriutzelGuiModule.imports = [
    ./lriutzel/gui.nix
    lriutzelTuiModule
  ];
  lriutzelFullModule.imports = [
    ./lriutzel/default.nix
    ./lriutzel/full.nix
    lriutzelGuiModule
  ];
  lriutzelModule.imports = [ lriutzelFullModule ];
in
{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      lriutzel = lriutzelModule;
      lriutzelFull = lriutzelFullModule;
      lriutzelGui = lriutzelGuiModule;
      lriutzelTui = lriutzelTuiModule;
      criutzel.imports = [ ./criutzel ];
      kodi.imports = [ ./kodi ];
    };
  };
}
