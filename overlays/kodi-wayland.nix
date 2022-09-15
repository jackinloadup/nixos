inputs:
let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
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
    #version = "v20.0a2";
    #src = super.fetchFromGitHub {
    #  owner  = "xbmc";
    #  repo   = "xbmc";
    #  rev    = "v20.0a2-Nexus";
    #  sha256 = "sha256-XDtmY3KthiD91kvueQRSamBcdM7fBpRntmZX6KRsCzE=";
    #};
    patches = old.patches ++ [
      ./kodi-wayland.patch
    ];
  });
}
