{ config, lib, ... }:
let
  inherit (lib) mkIf;
in {
  config = {
    services.frigate = {
      enable = true;
      #hostname = "frigate..us";
      #vaapiDriver = "radeonsi";
      settings = {
        mqtt = {
          enable = true;
          host = "127.0.0.1:1883";
        };
        cameras = { };
      };
    };
  };
}
