{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
in {
  imports = [];

  options.machine.vault = mkEnableOption "Enable bluetooth";

  config = mkIf config.machine.vault {
    gumdrop.storageServer.enable = true;
    services.vault = {
      enable = true;
      storagePath = "/gumdrop/active/vault";
      storageBackend = "file";
    };
    # VAULT_ADDR="http://127.0.0.1:8200";

    environment.systemPackages = with pkgs; [
      vault
      vsh
    ];
  };
}
