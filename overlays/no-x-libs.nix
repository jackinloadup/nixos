_flake: _self: super: {
  kodi-wayland = super.kodi-wayland.override { x11Support = false; };
  pipewire =
    (super.pipewire.override {
      x11Support = false;
    }).overrideAttrs (old: {
      mesonFlags =
        [
          "-Dx11-xfixes=disabled"
        ]
        ++ old.mesonFlags;
    });
}
