_flake:
_self: super: {
  pipewire =
    (super.pipewire.override {
      libcameraSupport = false;
      gstreamerSupport = false;
      ffmpegSupport = true;
      #bluezSupport = false;
      nativeHspSupport = false;
      nativeHfpSupport = false;
      ofonoSupport = false;
      hsphfpdSupport = false;
      pulseTunnelSupport = false;
      zeroconfSupport = false;
      raopSupport = false;
      rocSupport = false;
      x11Support = false;
    }).overrideAttrs (old: {
      mesonFlags =
        [
          "-Dx11-xfixes=disabled"
          "-Dlibcanberra=disabled"
          "-Dgstreamer-device-provider=disabled"
        ]
        ++ old.mesonFlags;
    });
}
