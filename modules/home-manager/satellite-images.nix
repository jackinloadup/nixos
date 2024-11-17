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
      #pkgs.jq
      pkgs.htmlq
      pkgs.aria2
      pkgs.fd
    ];

    # TODO on mobile devices we are missing images while sleeping
    text = ''
      set -o xtrace

      # NOAA API
      # File format
      # 20242760621_GOES16-ABI-CONUS-GEOCOLOR-5000x3000.jpg
      # yyyy day-of-year(j) hh mm
      #
      # Contains 14 days of images
      URL="https://cdn.star.nesdis.noaa.gov/GOES16/ABI/CONUS/GEOCOLOR/"

      #OUTDIR=$XDG_CACHE_HOME/satellite-images/goes-east
      OUTDIR=${cfg.cacheDir}

      # ensure directory exists
      mkdir -p "$OUTDIR"

      # download image index
      # filter to desired files
      # remove files already downloaded
      # prefix url to filename
      # download missing files
      curl -sS $URL \
        | htmlq --attribute href a 2>/dev/null \
        | rg GEOCOLOR-5000x3000.jpg \
        | xargs -I{} -n1 sh -c "test -e \"$OUTDIR/{}\" || echo '{}'" \
        | sed "s|^|$URL|g" \
        | aria2c --input-file=- \
                 --dir "$OUTDIR" \
                 --allow-overwrite=false \
                 --auto-file-renaming=false

      NEWEST_FILE=$(fd '^\d{11}_' "$OUTDIR" --type f --exec stat --format '%Y %n' \
                     | sort -n \
                     | tail -n 1 \
                     | awk '{print $2}')

      # Symlink the most current file for individual use
      ln -sfn "$NEWEST_FILE" "$OUTDIR/current.jpg"
    '';
  };

  createTimelapseScript =  pkgs.writeShellApplication {
    name = "satellite-image-timelapse";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.ffmpeg
    ];

    text = ''
      set -o xtrace

      #OUTDIR=$XDG_CACHE_HOME/satellite-images/goes-east
      OUTDIR=${cfg.cacheDir}

      cat "$OUTDIR"/*.jpg | ffmpeg -f image2pipe -i - "$OUTDIR"/output.mp4
    '';
  };

  deleteOldFilesScript =  pkgs.writeShellApplication {
    name = "satellite-image-cleaner";

    runtimeInputs = [
      pkgs.coreutils
    ];

    text = ''
      set -o xtrace

      #OUTDIR=$XDG_CACHE_HOME/satellite-images/goes-east
      OUTDIR=${cfg.cacheDir}

      # Delete files older than one week
      DAYS=14
      find "$OUTDIR" -type f -mtime +$DAYS -exec rm {} \;
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
      days = mkOption {
        type = types.int;
        default = 14;
        description = "How many days of context should be downloaded and kept";
      };
      generateTimelapse = mkEnableOption "Generate timelapse";
      cacheDir = mkOption {
        type = types.str;
        example = "$XDG_CACHE_HOME/satellite-images/goes-east";
        default = "$XDG_CACHE_HOME/satellite-images/goes-east";
        description = "Where will data be downloaded to";
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

    systemd.user.timers.satellite-image-timelapse = mkIf cfg.generateTimelapse {
      Unit = { Description = "Create timelapse video of satellite images"; };
      Install = { WantedBy = [ "timers.target" ]; };
      Timer = {
        OnBootSec = "1h";
        OnUnitActiveSec = "1h";
        OnUnitInactiveSec = "1h";
        Unit = "satellite-image-timelapse.service";
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

    systemd.user.services.satellite-image-timelapse = mkIf cfg.generateTimelapse {
      Unit = { Description = "Create timelapse of satellite images"; };
      Service = {
        Type = "oneshot";
        ExecStart = "${createTimelapseScript}/bin/satellite-image-timelapse";
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
