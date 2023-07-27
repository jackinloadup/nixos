{ pkgs, lib, ... }: let
  inherit (lib) mkForce;
in {
  config = {
    services.rtl_433 = {
      enable = true;
      package = pkgs.rtl_433-dev;
      configText = ''
        output json
        output mqtt://mqtt.home.lucasr.com,user=mosquitto,pass=mosquitto,retain=0,events=rtl_433[/model][/id]
        report_meta time:utc
        frequency 915M
        frequency 433.92M
        convert si
        hop_interval 60
        gain 0
      '';
    };
    systemd.services.rtl_433.wantedBy = mkForce []; # don't start automatically
  };
}
