_flake:
self: super: {
  plymouth = super.plymouth.overrideAttrs (old:
    let
      inherit (self.lib.lists) remove;
    in
    {
      buildInputs = remove self.gtk3 old.buildInputs;
      configureFlags =
        (remove "--enable-gtk" old.configureFlags)
        ++ [ "--disable-gtk" ];
    });
}
