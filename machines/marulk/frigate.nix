{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
in {
  config = {
    hardware.graphics.enable = true;

    systemd.tmpfiles.rules = [
      "d /dev/shm/logs/frigate/current 0755 frigate frigate"
    ];

    systemd.services.frigate.serviceConfig = {
      CacheDirectory = "frigate/preview_frames";
    };

    services.frigate = {
      enable = true;
      # 0.0.0.0 didn't seem to work
      hostname = "frigate.home.lucasr.com";
      vaapiDriver = "radeonsi";
      settings = {
        auth = {
# doesn't appear in 0.14.1 or 0.15??
#          enable = false; # make things easy for now. Don't really need it.
#reset_admin_password = true;
        };

        ffmpeg = {
          hwaccel_args = "preset-vaapi";
          input_args = [
            # for reolink camera
            "-avoid_negative_ts"
            "make_zero"
          ];
        };

        mqtt = {
          enabled = true;
          host = "mqtt.home.lucasr.com";
          port = 1883;
          user = "mosquitto";
          password = "mosquitto";
        };

        #go2rtc.enabled = false;
        #go2rtc = {
        #  streams = {
        #    front = "rtsp://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:554/h264Preview_01_main";
        #    front_sub = "rtsp://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:554/h264Preview_01_sub";
        #  };
        #  webrtc = {
        #    listen = ":8555";
        #    candidates = [
        #      "10.100.0.1:8555"
        #      "stun:8555"
        #    ];
        #  };
        #};

        cameras = {
          front = {
            #webui_url = "https://frigate.home.lucasr.com";
            detect = {
              width = 2560;
              height = 1920;
              fps = 5;
            };
            ffmpeg = {
              inputs = [
                {
                  #path = "rtsp://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:554/h264Preview_01_main";
                  path = "rtsp://go2rtc.home.lucasr.com:8554/front?mp4";
                  roles = [
                    "record"
                    "audio"
                  ];
                }
                {
                  #path = "rtsp://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:554/h264Preview_01_sub";
                  path = "rtsp://go2rtc.home.lucasr.com:8554/front_sub?mp4";
                  roles = [
                    "detect"
                  ];
                }
              ];
            };

            zones = {
              gumdrop = {
                coordinates = "0.796,0.412,0.514,0.239,0.468,0.201,0.555,0.188,0.806,0.26,0.997,0.354,0.995,0.522";
                objects = [
                  "person"
                  "car"
                ];
              };
              driveway = {
                coordinates = "0.641,0.363,0.995,0.582,0.997,0.737,0.42,0.942,0.278,0.544";
                objects = [
                  "person"
                ];
              };
            };
            motion = {
              mask = [
                "0,0.892,0.37,0.829,0.578,1,0,1"
                "0.573,0.18,1,0.35,0.999,0.003,0.548,0.001"
                "0.462,0.198,0.483,0.179,0.474,0.147,0.262,0.19,0.267,0.225"
              ];
            };
            objects = {
              mask = [
                "0.486,0.169,0.474,0.192,0.487,0.236,0.226,0.305,0.204,0.226,0.38,0.151"
                "0.58,0.181,1,0.331,1,0.049,0.583,0.032"
                "0.263,0.353,0.288,0.754,0.12,0.849,0.004,0.831,0,0.388"
              ];
            };
          };
        };


        objects = {
          track = [
            "person"
            "car"
          ];
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
        review = {
          alerts = {
            labels = [
              "car"
              "person"
            ];
            required_zones = [
              "driveway"
              "gumdrop"
            ];
          };

          detections = {
            labels = [
              "car"
              "person"
            ];

            required_zones = [
              "driveway"
              "gumdrop"
            ];
          };
        };

        snapshots = {
          enabled = true;
          retain.default = 30; # days
        };
      };
    };

    systemd.services.go2rtc.serviceConfig.Restart = "on-failure";
    services.go2rtc = {
      enable = true;
      settings = {
        api = {
          origin = "*";
        };

        webrtc = {
          listen = ":8555";
          candidates = [
            "10.100.0.1:8555"
            "stun:8555"
          ];
        };
        streams = {
          #front = "rtsp://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:554/h264Preview_01_main";
          #front_sub = "rtsp://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:554/h264Preview_01_sub";

          #front = "ffmpeg:rtsp://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:554/h264Preview_01_main#video=copy#audio=copy#audio=opus";
          #front_sub = "ffmpeg:rtsp://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:554/h264Preview_01_sub#video=copy#audio=copy#audio=opus";

          front = [
            "onvif://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:8000?subtype=000"
            "ffmpeg:front#audio=opus"
          ];
          front_sub = [
            "onvif://go2rtc:g0nQCcGL8T38Sp@camera1.home.lucasr.com:8000?subtype=001"
            "ffmpeg:front#audio=opus"
          ];
        };
      };
    };
  };
}
