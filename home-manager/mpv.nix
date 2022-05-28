{ inputs, pkgs, config, lib, nixosConfig, ... }:

let
  inherit (lib.attrsets) genAttrs;
  settings = import ../settings;
in
{
  programs.mpv = {
    enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
    config = {
      force-window = true;
      video-sync ="display-resample";
      interpolation =true;
      ytdl-format = "bestvideo+bestaudio"; #TODO adjust for laptop screen size

      # hardware accelerate
      hwdec = "auto-safe"; # battery
      profile = "gpu-hq";
      vo="gpu";
      gpu-context="wayland";

      # language
      alang="${settings.user.langCode},eng"; # audio language, multiple possible
      slang="${settings.user.langCode},eng"; # subtitle language
      #cache-default = 4000000;
      #tscale = "oversample";
    };
  };

  xdg.mimeApps.defaultApplications = genAttrs [
    "application/mxf"
    "application/sdp"
    "application/smil"
    "application/streamingmedia"
    "application/vnd.apple.mpegurl"
    "application/vnd.ms-asf"
    "application/vnd.rn-realmedia"
    "application/vnd.rn-realmedia-vbr"
    "application/x-cue"
    "application/x-extension-m4a"
    "application/x-extension-mp4"
    "application/x-matroska"
    "application/x-mpegurl"
    "application/x-ogm"
    "application/x-ogm-video"
    "application/x-shorten"
    "application/x-smil"
    "application/x-streamingmedia"
    "video/3gp"
    "video/3gpp"
    "video/3gpp2"
    "video/avi"
    "video/divx"
    "video/dv"
    "video/fli"
    "video/flv"
    "video/mkv"
    "video/mp2t"
    "video/mp4"
    "video/mp4v-es"
    "video/mpeg"
    "video/msvideo"
    "video/ogg"
    "video/quicktime"
    "video/vnd.divx"
    "video/vnd.mpegurl"
    "video/vnd.rn-realvideo"
    "video/webm"
    "video/x-avi"
    "video/x-flc"
    "video/x-flic"
    "video/x-flv"
    "video/x-m4v"
    "video/x-matroska"
    "video/x-mpeg2"
    "video/x-mpeg3"
    "video/x-ms-afs"
    "video/x-ms-asf"
    "video/x-ms-wmv"
    "video/x-ms-wmx"
    "video/x-ms-wvxvideo"
    "video/x-msvideo"
    "video/x-ogm"
    "video/x-ogm+ogg"
    "video/x-theora"
    "video/x-theora+ogg"
  ] (name: "mpv.desktop");
}
