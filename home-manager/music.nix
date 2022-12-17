{ pkgs, lib, nixosConfig, ... }:

let 
  isGraphical = nixosConfig.machine.sizeTarget > 1;
in {

  config = lib.mkIf isGraphical {
    home.packages = with pkgs; [
      ncmpcpp
    ];

    services.mopidy = {
      enable = true;
      extensionPackages = with pkgs; [
        # mopidy-spotify #removed because Spotify stopped supporting libspotify
        # mopidy-local
        mopidy-mpd
        mopidy-mpris
        mopidy-somafm
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
