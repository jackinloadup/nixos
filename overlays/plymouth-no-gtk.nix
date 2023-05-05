inputs: let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
  inherit inputs;
  #cp = f: (super.callPackage f) {};
in
  self: super: {
    plymouth = super.plymouth.overrideAttrs (old: let
      remove = self.lib.lists.remove;
    in {
      buildInputs = remove self.gtk3 old.buildInputs;
      configureFlags =
        (remove "--enable-gtk" old.configureFlags)
        ++ ["--disable-gtk"];
    });
  }
