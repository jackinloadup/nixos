{ lib, pkgs, config, inputs, ... }:

let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    inputs.base16.hmModule
  ];

  config = {
    themes.base16 = with settings.theme; {
      enable = true;
      scheme = base16.scheme;
      variant = base16.variant;
      defaultTemplateType = "default";
      # Add extra variables for inclusion in custom templates
      # not sure the "extraParams" are being used. No custom templates afaik
      extraParams = {
        fontName = font.mono.family;
        fontSize = font.size;
      };
    };
  };
}
