{...}: {
  nixpkgs.config.permittedInsecurePackages = [
    "libxls-1.6.2" # dependency of sc-im
    "nix-2.16.2"
    "nextcloud-27.1.11"
  ];
}
