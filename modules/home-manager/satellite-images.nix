{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.services.satellite-images;
  script =  pkgs.writeShellApplication {
    name = "satellite-image-downloader";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];

    # TODO on mobile devices we are missing images while sleeping
    text = ''
      set -o xtrace

      DATE=$(date +'%s')
      OUTDIR=$XDG_CACHE_HOME/satellite-images/goes-east
      OUTPUT=$OUTDIR/$DATE.jpg

      # ensure directory exists
      mkdir -p "$OUTDIR"

      IMAGE_URL=$(
        curl -s "https://spaceeye-satellite-configs.s3.us-east-2.amazonaws.com/1.2.0/config.json" \
         | jq '.satellites | map(select(.name | contains("GOES-East"))) | .[0].views | map(select(.name | contains("Continental US"))) | .[0].imageSources | [last] | .[].url' -r
      )

      curl "$IMAGE_URL" --output "$OUTPUT"
      rm "$OUTDIR/current.jpg" || true
      ln -s "$OUTPUT" "$OUTDIR/current.jpg"

    '';
  };

  deleteOldFilesScript =  pkgs.writeShellApplication {
    name = "satellite-image-cleaner";

    runtimeInputs = [
      pkgs.coreutils
    ];

    text = ''
      set -o xtrace

      OUTDIR=$XDG_CACHE_HOME/satellite-images/goes-east

      # Delete files older than one week
      find "$OUTDIR" -type f -mtime +7 -exec rm {} \;
    '';
  };

  loopImagesScript =  pkgs.writeShellApplication {
    name = "satellite-image-loop";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.swww
    ];

    text = ''
      # https://github.com/LGFae/swww/blob/main/example_scripts/swww_randomize.sh
      # This script will randomly go through the files of a directory, setting it
      # up as the wallpaper at regular intervals
      #
      # NOTE: this script is in bash (not posix shell), because the RANDOM variable
      # we use is not defined in posix

      #if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
      #	echo "Usage:
      #	$0 <dir containing images>"
      #	exit 1
      #fi

      DIRECTORY="$HOME/.cache/satellite-images/goes-east"

      # Edit below to control the images transition
      export SWWW_TRANSITION_FPS=60
      export SWWW_TRANSITION_STEP=2

      # This controls (in seconds) when to switch to the next image
      INTERVAL=1

      while true; do
      	find "$DIRECTORY" -type f \
      		| while read -r img; do
      			swww img "$img"
      			sleep $INTERVAL
      		done
      done
    '';
  };

in {
  options = {
    services.satellite-images = {
      enable = mkEnableOption "Enable service to grab latest satellite images";
      satellite = mkOption {
        type = types.str;
        example = "GOES-West";
        default = "GOES-East";
        description = "Which GOES satellite to pull from?";
      };
      view = mkOption {
        type = types.str;
        example = "Continental US";
        default = "Continental US";
        description = "Which view from the choosen satellite?";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.timers.satellite-image-downloader = {
      Unit = { Description = "Automatic satellite image download synchronization"; };
      Install = { WantedBy = [ "timers.target" ]; };
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "15m";
        OnUnitInactiveSec = "15m";
        Unit = "satellite-image-downloader.service";
        Persistent = true;
      };
    };

    systemd.user.timers.satellite-image-cleaner = {
      Unit = { Description = "Clean out old satellite images"; };
      Install = { WantedBy = [ "timers.target" ]; };
      Timer = {
        Unit = "satellite-image-cleaner.service";
        OnCalendar = "weekly";
        Persistent = true;
      };
    };

    systemd.user.services.satellite-image-downloader = {
      Unit = { Description = "Automatic satellite image download"; };
      Service = {
        Type = "oneshot";
        #getExe?
        ExecStart = "${script}/bin/satellite-image-downloader";
      };
    };

    systemd.user.services.satellite-image-cleaner = {
      Unit = { Description = "Clean satellite images"; };
      Service = {
        Type = "oneshot";
        #getExe?
        ExecStart = "${deleteOldFilesScript}/bin/satellite-image-cleaner";
      };
    };

    systemd.user.services.satellite-image-loop = {
      Unit = { Description = "Loop satellite images"; };
      Service = {
        Type = "oneshot";
        #getExe?
        ExecStart = "${loopImagesScript}/bin/satellite-image-loop";
      };
    };
  };
}
