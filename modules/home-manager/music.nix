{ pkgs
, lib
, config
, ...
}:
let
  inherit (lib) mkIf mkDefault;
in
{
  # Repo with lots of radio stations
  # https://github.com/junguler/m3u-radio-music-playlists.git
  config = mkIf config.services.mopidy.enable {
    home.packages = [
      pkgs.ncmpcpp
      #songrec # SHAZAM!
      #ytdlpAudio # My custom script for downloading music with yt-dlp.
      pkgs.picard # Graphical beets.
    ];

    services.mpris-proxy.enable = true;

    # Configure a MPD client.
    #    programs.ncmpcpp = {
    #      enable = true;
    #      mpdMusicDir = musicDir;
    #    };

    services.mopidy = {
      extensionPackages = [
        # pkgs.mopidy-spotify #removed because Spotify stopped supporting libspotify
        pkgs.mopidy-local
        pkgs.mopidy-mpd
        pkgs.mopidy-mpris
        pkgs.mopidy-somafm

        #pkgs.mopidy-beets
        #pkgs.mopidy-funkwhale
        #pkgs.mopidy-internetarchive
        pkgs.mopidy-iris
        #pkgs.mopidy-local
        #pkgs.mopidy-mpd
        #pkgs.mopidy-mpris
        pkgs.mopidy-youtube
      ];
      settings = {
        http = {
          hostname = "127.0.0.1";
          port = 6680;
          default_app = "iris";
        };

        file = {
          enabled = true;
          media_dirs = [
            "$XDG_MUSIC_DIR|Music"
            "/mnt/gumdrop/media/Music/Lossless|Lossless"
            "/mnt/gumdrop/media/Music/Lossy|Lossy"
            "/mnt/gumdrop/media/Music/Linux|iTunes Library"
          ];
          follow_symlinks = true;
          excluded_file_extensions = [
            ".html"
            ".zip"
            ".jpg"
            ".jpeg"
            ".png"
          ];
        };

        internetarchive = {
          enabled = true;
          browse_limit = 150;
          search_limit = 150;
          collections = [
            "fav-foo-dogsquared"
            "audio"
            "etree"
            "audio_music"
            "audio_foreign"
          ];
        };

        #        m3u = {
        #          enabled = true;
        #          base_dir = musicDir;
        #          playlists_dir = playlistsDir;
        #          default_encoding = "utf-8";
        #          default_extension = ".m3u8";
        #        };
      };
    };
  };
}
