{ lib, pkgs, config, ... }:
with lib;
let
  settings = import ../../settings;
in {
  imports = [];

  options.gumdrop.pihole = mkEnableOption "Enable pihole container";

  config = mkIf config.gumdrop.pihole {
    virtualisation.oci-containers.containers."pihole" = {
      image = "pihole/pihole:2022.01.1";
      #dependsOn = [ "unbound" ];
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "80:80/tcp"
        "443:443/tcp"
      ];
      environment = {
        TZ = settings.home.timezone;
        WEBPASSWORD = "2345";
        DNS1 = "1.1.1.1#53";
        DNS2 = "1.0.0.1#53";
      };
      volumes = [ "pihole:/etc/pihole" ];
      extraOptions = [
        #"--network=pihole-unbound"
        #"--ip=172.19.0.2"
        "--net=host"
      ];
    };
  };
}
