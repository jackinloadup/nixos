{
  lib,
  pkgs,
  config,
  ...
}: let
  musicDir = config.xdg.userDirs.music;
  playlistsDir = "${musicDir}/playlists";
in {
  imports = [
  ];

  config = {
    home.packages = with pkgs; [
      songrec # SHAZAM!
      #ytdlpAudio # My custom script for downloading music with yt-dlp.
      picard # Graphical beets.
    ];

    programs.beets = {
      enable = true;
      settings = {
        library = "${musicDir}/library.db";
        plugins = [
          "acousticbrainz"
          "chroma"
          "edit"
          "export"
          "fetchart"
          "fromfilename"
          "fuzzy"
          "mbsync"
          "playlist"
          "scrub"
          "smartplaylist"
        ];
        ignore_hidden = true;
        directory = musicDir;
        ui.color = true;

        import = {
          move = false;
          link = false;
          resume = true;
          incremental = true;
          group_albums = true;
          log = "beets.log";
        };

        match.ignore_video_tracks = true;

        # Plugins configuration.
        fuzzy.prefix = "-";
        scrub.auto = true;
        smartplaylist = {
          relative_to = musicDir;
          playlist_dir = playlistsDir;
          playlists = [
            {
              name = "all.m3u8";
              query = "";
            }
            {
              name = "released-in-$year.m3u8";
              query = "year:2000..2023";
            }
          ];
        };
      };
    };

    # Add more cleaners.
    services.bleachbit.cleaners = [
      "audacious.log"
      "audacious.cache"
      "audacious.mru"
      "vlc.memory_dump"
      "vlc.mru"
    ];
  };
}
