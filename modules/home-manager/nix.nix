{
  flake,
  pkgs,
  config,
  lib,
  nixosConfig,
  ...
}: {
  config = {
    # doesn't work when home-manager.useGlobalPkgs is true
    #nixpkgs.config.allowUnfree = true;
    # inherit the systems overlays
    #nixpkgs.overlays =
    #  nixosConfig.nixpkgs.overlays
    #  ++ [
    #    flake.inputs.nur.overlay
    #  ];

    # expose registry items that are relevant outside of nixos
    #nix.registry = nixosConfig.nix.registry;

    #nix.package = pkgs.nix;
    #nix.package = pkgs.nixVersions.nix_2_20;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
    '';
    # plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins # https://github.com/shlevy/nix-plugins
  };
}
