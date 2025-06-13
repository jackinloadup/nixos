{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  settings = import ../../../settings;
  ifTui = config.machine.sizeTarget > 0;
  ifGraphical = config.machine.sizeTarget > 1;
in {
  config = with settings.theme.font; {
    #console.font = mkIf ifTui console;
    console.packages = [ pkgs.terminus_font ];
    console.font = "ter-v12n";
      ## High-DPI console.
      #console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    fonts = mkIf ifGraphical {
      fontconfig = {
        enable = mkDefault true;
        antialias = mkDefault true;
        defaultFonts = {
          serif = [serif.family];
          sansSerif = [normal.family];
          monospace = [mono.family];
          emoji = [emoji.family];
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
      packages = [
        # Nerdfonts is kinda heavy. We are cutting it down but still looks like it might be 4-10mb
        #(pkgs.nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];}) # unstable broke package apart
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.droid-sans-mono
        pkgs.lato
        pkgs.noto-fonts-emoji
      ];
    };
  };
}
