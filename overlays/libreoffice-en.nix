inputs:
self: super: {
  # Causes long rebuild. Unclear how much value is added at this point.
  # rebuilds libreoffice as well as webkit I belive
  libreoffice = (super.libreoffice.override {
    langs = ["en-US"];
  });
}
