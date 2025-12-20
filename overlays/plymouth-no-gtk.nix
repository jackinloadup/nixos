flake:
let
  #cp = f: (super.callPackage f) {};
in
self: super: {
  plymouth = super.plymouth.overrideAttrs (old:
    let
      remove = self.lib.lists.remove;
    in
    {
      buildInputs = remove self.gtk3 old.buildInputs;
      configureFlags =
        (remove "--enable-gtk" old.configureFlags)
        ++ [ "--disable-gtk" ];
    });
}
