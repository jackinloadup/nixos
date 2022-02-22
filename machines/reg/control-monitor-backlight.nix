{ self, inputs, pkgs, lib, ... }:

let
  settings = import ../../settings;
in {
  hardware.i2c.enable = true;
  services.ddccontrol.enable = true;
  # pkgs that might be desired
  # ddccontrol-db
  # i2c-tools
  users.users = with settings.user; {
    ${username} = {
      extraGroups = [ "i2c" ];
    };
  };
}
