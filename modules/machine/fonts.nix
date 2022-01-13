{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  config = {
    fonts = mkIf (cfg.sizeTarget > 0) {
      fontconfig = with settings.theme.font; {
        enable = true;
        antialias = true;
        defaultFonts = {
          serif = [ serif.family ];
          sansSerif = [ normal.family ];
          monospace = [ mono.family ];
          emoji = [ emoji.family ];
        };

        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <alias binding="weak">
              <family>monospace</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>
            <alias binding="weak">
              <family>sans-serif</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>
            <alias binding="weak">
              <family>serif</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>
          </fontconfig>
        '';
      };
      fonts = with pkgs; [
        # Nerdfonts is kinda heavy. We are cutting it fown but still looks like it might be 4-10mb
        (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
        lato
        noto-fonts-emoji
      ];
    };
  };
}
