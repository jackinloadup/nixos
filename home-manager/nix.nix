{ inputs, pkgs, config, lib, nixosConfig, ... }:

with inputs;
let
  settings = import ../settings;
  ifGraphical = if (nixosConfig.machine.sizeTarget > 1) then true else false;
in
{

    nixpkgs.config.allowUnfree = true;
    # inherit the systems overlays
    nixpkgs.overlays = nixosConfig.nixpkgs.overlays ++ [
      nur.overlay
    ];

    nix.package = pkgs.nix;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
    '';
}
