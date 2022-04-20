{ lib, pkgs, config, ... }:
with lib;
{
  imports = [];

  options.machine.vault = mkEnableOption "Enable bluetooth";

  config = mkIf config.machine.vault {
    gumdrop.storageServer = true;
    services.vault = {
      enable = true;
      storagePath = "/gumdrop/active/vault";
      storageBackend = "file";
    };

    environment.systemPackages = with pkgs; [
      vault
      vsh
    ];
  };
}
