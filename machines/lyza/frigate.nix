{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  secrets = config.age.secrets;
in {
  config = {
    hardware.graphics.enable = true;

    systemd.services.frigate.serviceConfig.EnvironmentFile = secrets.lyza-frigate.path;

    services.frigate = {
      enable = true;
# 0.15 doesn't appear in nixpkgs-unstable
#package = pkgs.unstable.frigate;
      # 0.0.0.0 didn't seem to work
      hostname = "127.0.0.1";
      #vaapiDriver = "radeonsi";
      settings = {
#        auth = {
# doesn't appear in 0.14.1
#enable = false; # make things easy for now. Don't really need it.
#reset_admin_password = true;
#        };

        ffmpeg.hwaccel_args = "preset-vaapi";

        mqtt = {
          enabled = true;
          host = "127.0.0.1";
          port = 1883;
          user = "{FRIGATE_MQTT_USER}";
          password = "{FRIGATE_MQTT_PASSWORD}";
        };

        cameras = {
          front = {
            webui_url = "http://camera1";
            detect = {
              width = 2560;
              height = 1920;
              fps = 5;
            };
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_PASSWORD}@192.168.1.111:554/h264Preview_01_main";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_PASSWORD}@192.168.1.111:554/h264Preview_01_sub";
                  roles = [ "detect" ];
                }
              ];
            };
            motion = {
              mask = [
                "0.000,0.427,0.002,0.000,0.999,0.000,0.999,0.781,0.885,0.456,0.700,0.424,0.701,0.311,0.507,0.294,0.453,0.347,0.451,0.400"
              ];
            };
          };
        };

        detectors = {
          coral = {
            type = "edgetpu";
            device = "usb";
          };
        };

        record = {
          enabled = true;
          retain = {
            days = 7;
            mode = "motion";
          };
#          alerts.retain.days = 30;
#          detections.retain.days = 30;
        };

        snapshots = {
          enabled = true;
          retain.default = 30; # days
        };
      };
    };
  };
}
