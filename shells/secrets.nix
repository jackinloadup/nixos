{ pkgs ? import <nixpkgs> { } }:
let
  provision-secrets = import ../packages/provision-secrets.nix { inherit pkgs; };
in
pkgs.mkShell {
  name = "Secrets";
  packages = [
    pkgs.jq
    pkgs.nebula # generate nebula keys
    pkgs.mkp224o # generate tor service keys
    pkgs.wireguard-tools
    pkgs.ragenix
    pkgs.age
    pkgs.libargon2 # for vaultwarden - https://github.com/dani-garcia/vaultwarden/wiki/Enabling-admin-page
    pkgs.openssl # for vaultwarden
    provision-secrets # generate and encrypt machine secrets
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
  #'';
}
