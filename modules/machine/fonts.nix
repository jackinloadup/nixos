{ lib, pkgs, config, ... }:
with lib;
let
  settings = import ../../settings;
  ifTui = if (config.machine.sizeTarget > 0) then true else false;
  ifGraphical = if (config.machine.sizeTarget > 1) then true else false;
in {
  config = with settings.theme.font; {
    console.font = mkIf ifTui console;
    fonts = mkIf ifGraphical {
      fontconfig = {
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
        # Nerdfonts is kinda heavy. We are cutting it down but still looks like it might be 4-10mb
        (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
        lato
        noto-fonts-emoji
      ];
    };
  };
}
