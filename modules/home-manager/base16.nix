{
  pkgs,
  config,
  lib,
  nixosConfig,
  flake,
  ...
}: let
  settings = import ../../settings;
in {
  imports = [
    flake.inputs.base16.hmModule
  ];

  config = {
    themes.base16 = with settings.theme; {
      enable = true;
      scheme = base16.scheme;
      variant = base16.variant;
      defaultTemplateType = "default";
      # Add extra variables for inclusion in custom templates
      extraParams = {
        fontName = font.mono.family;
        fontSize = font.size;
      };
    };
  };
}
