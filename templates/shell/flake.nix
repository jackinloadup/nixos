{
  description = "Project";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs;
    flake-parts.url = github:hercules-ci/flake-parts;
    flake-utils.url = github:numtide/flake-utils;
    treefmt-nix.url = github:numtide/treefmt-nix;
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        devShells = flake-utils.lib.flattenTree {
          default = pkgs.mkShell {
            name = "Project";
            packages = with pkgs; [
              # pkgs
            ];
            #NIX_LD_LIBRARY_PATH = with pkgs; nixpkgs.lib.makeLibraryPath [
            #  stdenv.cc.cc
            #  openssl
            #];
            #NIX_LD = pkgs.runCommand "ld.so" {} ''
            #  ln -s "$(cat '${pkgs.stdenv.cc}/nix-support/dynamic-linker')" $out
            #'';
            #shellHook = ''
            #  export AWS_PROFILE="project"
            #  export AWS_REGION="us-east-2"
            #  export PATH="$PATH:$HOME/Projects/nix/ddev"
            #  echo "Loaded DrupalStand Shell. Using $AWS_PROFILE in $AWS_REGION"
            #'';
          };
        };
      }
    );
}
