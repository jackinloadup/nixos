{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault;
in {
  # Repo with lots of radio stations
  # https://github.com/junguler/m3u-radio-music-playlists.git
  config = mkIf config.services.mopidy.enable {
    home.packages = with pkgs; [
      ncmpcpp
    ];

    services.mpris-proxy.enable = true;


    services.mopidy = {
      extensionPackages = [
        # pkgs.mopidy-spotify #removed because Spotify stopped supporting libspotify
        pkgs.mopidy-local
        pkgs.mopidy-mpd
        pkgs.mopidy-mpris
        pkgs.mopidy-somafm
      ];
      settings = {
        file = {
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
      };
    };
  };
}
