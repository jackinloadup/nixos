{ lib, pkgs, config, ... }:

let

in {
  config = {

    home.packages = [
      pkgs.openrct2
    ];
  };
}
