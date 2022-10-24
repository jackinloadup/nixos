inputs:
let
  inherit inputs;
  #cp = f: (super.callPackage f) {};
in self: super: {
  kodi-wayland = (self.unstable.kodi-wayland.override {
    joystickSupport = false;
    x11Support = false;
    nfsSupport = false;
    sambaSupport = false;
  })
  .overrideAttrs(old: {
    patches = old.patches ++ [
      ../patches/kodi-workaround-blank-screen.patch
    ];
  });
}
