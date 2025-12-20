flake: self: super: {
  kodi-wayland =
    (self.unstable.kodi-wayland.overrideAttrs (old: {
      passthru =
        old.passthru
        // {
          patches =
            old.patches
            ++ [
              ../patches/kodi-workaround-blank-screen.patch
              ../patches/kodi-scancode.patch
            ];
          withPackages = old.passthru.withPackages (kodiPkgs:
            with kodiPkgs; [
              #  keymap
              visualization-waveform
              #self.unstable.kodiPackages.visualization-waveform
            ]);
        };
    })).override {
      joystickSupport = true;
      gbmSupport = false;
      nfsSupport = false;
      sambaSupport = false;
      x11Support = false;
    };
}
