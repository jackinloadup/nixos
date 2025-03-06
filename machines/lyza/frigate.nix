{ config, lib, ... }:
let
  inherit (lib) mkIf;
in {
  config = {
    services.frigate = {
      enable = true;
      hostname = "127.0.0.1";
      #vaapiDriver = "radeonsi";
      settings = {
        mqtt = {
          enabled = true;
          host = "127.0.0.1:1883";
        };
        cameras = { };

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
          retain.default = 30;
        };

#ffmpeg:
#  hwaccel_args: preset-rpi-64-h264

#
#cameras:
#  name_of_your_camera:
#    detect:
#      width: 1280
#      height: 720
#      fps: 5
#    ffmpeg:
#      inputs:
#        - path: rtsp://10.0.10.10:554/rtsp
#          roles:
#            - detect
#    motion:
#      mask:
#        - 0.000,0.427,0.002,0.000,0.999,0.000,0.999,0.781,0.885,0.456,0.700,0.424,0.701,0.311,0.507,0.294,0.453,0.347,0.451,0.400
      };
    };
  };
}
