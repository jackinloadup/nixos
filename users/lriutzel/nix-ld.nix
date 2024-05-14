{pkgs, ...}: {
  config = {
    #programs.nix-ld.dev.enable = isFullSystem; # dev = using flake vs nixpkgs
    # TODO when possible pull from programs.myapp.package
    programs.nix-ld.libraries = [
      pkgs.SDL2
      pkgs.SDL2_image
      pkgs.SDL2_sound
      pkgs.SDL2_gfx
      pkgs.SDL2_net
      pkgs.SDL2_ttf
      pkgs.openxr-loader
      pkgs.libcap
      pkgs.gvfs
      pkgs.dconf
      pkgs.gcc
      pkgs.libgcc
      pkgs.steam
      #pkgs.zstd
      pkgs.stdenv.cc.cc
      pkgs.libcef
      pkgs.rocmPackages.clr # for AMD only. TODO

      #added while trying to get steamvr working
      pkgs.freetype
      pkgs.pixman
      pkgs.libuuid
      pkgs.avahi
      pkgs.libgssglue # maybe
      pkgs.libpng


      pkgs.waylandpp

      # from TUM-DSE_doctor-cluster-config/modules/nix-ld.nix
      pkgs.fuse3
      pkgs.alsa-lib
      pkgs.at-spi2-atk
      pkgs.atk
      pkgs.cairo
      pkgs.cups
      pkgs.curl
      pkgs.dbus
      pkgs.expat
      pkgs.fontconfig
      pkgs.gdk-pixbuf
      pkgs.glib
      pkgs.gtk2
      pkgs.gtk3
      pkgs.libGL
      pkgs.libappindicator-gtk3
      pkgs.libdrm
      pkgs.libnotify
      pkgs.libpulseaudio
      pkgs.libxkbcommon
      pkgs.mesa
      pkgs.nspr
      pkgs.nss
      pkgs.pango
      pkgs.pipewire
      pkgs.systemd
      pkgs.xorg.libX11
      pkgs.xorg.libXScrnSaver
      pkgs.xorg.libXcomposite
      pkgs.xorg.libXcursor
      pkgs.xorg.libXdamage
      pkgs.xorg.libXext
      pkgs.xorg.libXfixes
      pkgs.xorg.libXi
      pkgs.xorg.libXrandr
      pkgs.xorg.libXrender
      pkgs.xorg.libXtst
      pkgs.xorg.libxkbfile
      pkgs.xorg.libxshmfence
      pkgs.xorg.libXft
      pkgs.xorg.libxcb
      pkgs.zlib
      #(lib.lowPrio pkgs.ncurses5) # xgdb from xilinx vitis
      #pkgs.ncurses
      #pkgs.libxcrypt
    ];
  };
}
