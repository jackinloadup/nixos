{ config, pkgs, nixosConfig, lib, inputs, ... }:

let
  settings = import ../settings;
in {
    services = {
      gpg-agent = {
        enable = true;
        enableExtraSocket = false;
        enableScDaemon = false;
        enableSshSupport = true;
        defaultCacheTtl = 30;
        defaultCacheTtlSsh = 30;
        maxCacheTtl = 3600; # 1 hour
        maxCacheTtlSsh = 3600; # 1 hour
      };
    };
}
