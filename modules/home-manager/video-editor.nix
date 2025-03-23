{
  flake,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = [
    ./flatpak.nix
  ];

  config = {
     # If kdenlive give more grief, maybe look into distrobox
     services.flatpak.enable = mkDefault true;
     services.flatpak.packages = [
       #{ appId = "com.brave.Browser"; origin = "flathub";  }
       #"com.obsproject.Studio"
       #"im.riot.Riot"
       "org.kde.kdenlive"
       #"org.gnome.gitlab.somas.Apostrophe" # distraction-free markdown editor
     ];
     programs.obs-studio = {
       enable = mkDefault true;
       plugins = [
         pkgs.obs-studio-plugins.wlrobs
         pkgs.obs-studio-plugins.obs-multi-rtmp
       ];
     };
    # kdenlive is disabled below because it simply doesn't appear to work. I
    # couldn't get Christine's save files to open. I put her on flatpak because
    # of issues and after trying to figure it out again, flatpak is the way to
    # go.
    home.packages = [
      pkgs.mkvtoolnix
      pkgs.handbrake
      pkgs.blender # 3D render
      #pkgs.kdenlive # video editor
      #pkgs.libsForQt5.kdenlive
          #wrapProgram $out/bin/kdenlive --prefix LADSPA_PATH : ${pkgs.rnnoise-plugin}/lib/ladspa
      #(pkgs.kdenlive.overrideAttrs (prevAttrs: {
      #  nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.makeBinaryWrapper ];
      #  postInstall = (prevAttrs.postInstall or "") + ''
      #    wrapProgram $out/bin/kdenlive --prefix LADSPA_PATH : ${pkgs.ladspaPlugins}/lib/ladspa
      #  '';
      #}))
      ## used in kdenlive
      #pkgs.ffmpeg-full
      #pkgs.mediainfo

      ## plugins
      #pkgs.glaxnimate
      #pkgs.movit
      #pkgs.frei0r

      ## plugins Unsure if all of these are needed
      #pkgs.ladspaH
      #pkgs.ladspaPlugins
      #pkgs.lsp-plugins


    ];

    # commented paths just don't have their packages installed. or at least
    # don't show up in the path system path
    #environment.variables = {
    #  #DSSI_PATH   = "$HOME/.dssi:$HOME/.nix-profile/lib/dssi:/run/current-system/sw/lib/dssi";
    #  LADSPA_PATH = "$HOME/.ladspa:$HOME/.nix-profile/lib/ladspa:/run/current-system/sw/lib/ladspa";
    #  LV2_PATH    = "$HOME/.lv2:$HOME/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2";
    #  #LXVST_PATH  = "$HOME/.lxvst:$HOME/.nix-profile/lib/lxvst:/run/current-system/sw/lib/lxvst";
    #  VST_PATH    = "$HOME/.vst:$HOME/.nix-profile/lib/vst:/run/current-system/sw/lib/vst";
    #};
  };
}

