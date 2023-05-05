{ inputs, pkgs, config, lib, nixosConfig, ... }:

{
  config = {
    nixpkgs.config.allowUnfree = true;
    # inherit the systems overlays
    nixpkgs.overlays = nixosConfig.nixpkgs.overlays ++ [
      inputs.nur.overlay
    ];

    # expose registry items that are relevant outside of nixos
    #nix.registry = nixosConfig.nix.registry;

    #nix.package = pkgs.nix;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
    '';
  };
}
