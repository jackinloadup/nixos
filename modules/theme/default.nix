{ lib, pkgs, config, inputs, ... }:

let
  inherit (lib) mkIf mkEnableOption types fetchFromGitHub;
  settings = import ../../settings;
in {
  options.machine.starlight = mkEnableOption "Enable startlight base16 theme";

  config = mkIf config.machine.starlight {
    themes.base16 = {
      enable = true;
      scheme = settings.theme.base16.scheme;
      variant = settings.theme.base16.variant;
      defaultTemplateType = "default";
      # Add extra variables for inclusion in custom templates
      extraParams = {
        fontName = settings.theme.font.mono.family;
        fontSize = settings.theme.font.size;
      };
    };

    environment.systemPackages =
      let
        cfg = config.machine.starlight;
        theme = config.lib.base16.theme;
        toPx = pt: pt * 4 / 3;
        starlight-oomox-theme = with pkgs; stdenv.mkDerivation rec {
          name = "starlight-oomox-theme-v1.0";
          src = fetchFromGitHub {
            owner = "themix-project";
            repo = "oomox";
            rev = "1.13.3";
            sha256 = "0krhvd73gm8znfr088l9d5195y6c7bsabdpf7fjdivjcrjv1a9qz";
            fetchSubmodules = true;
          };
          dontBuild = true;
          nativeBuildInputs = [ glib libxml2 bc ];
          buildInputs = [ gnome3.gnome-themes-extra gdk-pixbuf librsvg pkgs.sassc pkgs.inkscape pkgs.optipng ];
          propagatedUserEnvPkgs = [ gtk-engine-murrine ];
          installPhase = ''
            # icon theme
            mkdir -p $out/share/icons/Starlight
            pushd plugins/icons_suruplus_aspromauros
            patchShebangs .
            export SURUPLUS_GRADIENT_ENABLED=True
            export SURUPLUS_GRADIENT1=${theme.base00-hex}
            export SURUPLUS_GRADIENT2=${theme.base05-hex}
            ./change_color.sh -o Starlight -d $out/share/icons/Starlight -c ${theme.base03-hex}
            popd
            # gtk theme
            mkdir -p $out/share/themes/Starlight
            pushd plugins/theme_oomox
            patchShebangs .
            echo "
            BG=${theme.base00-hex}
            FG=${theme.base03-hex}
            HDR_BG=${theme.base00-hex}
            HDR_FG=${theme.base03-hex}
            SEL_BG=${theme.base0D-hex}
            SEL_FG=${theme.base00-hex}
            TXT_BG=${theme.base00-hex}
            TXT_FG=${theme.base03-hex}
            BTN_BG=${theme.base07-hex}
            BTN_FG=${theme.base03-hex}
            HDR_BTN_BG=${theme.base05-hex}
            HDR_BTN_FG=${theme.base03-hex}
            WM_BORDER_FOCUS=${theme.base0D-hex}
            WM_BORDER_UNFOCUS=${theme.base05-hex}
            ACCENT_BG=${theme.base0B-hex}
            ACCENT_FG=${theme.base03-hex}
            WM_BORDER_WIDTH=0
            ROUNDNESS=4
            SPACING=4
            GRADIENT=0.6
            GTK3_GENERATE_DARK=True
            CARET1_FG=${theme.base07-hex}
            CARET2_FG=${theme.base00-hex}
            CARET_SIZE=0.08
            OUTLINE_WIDTH=${toString settings.theme.borderWidth}
            BTN_OUTLINE_WIDTH=${toString settings.theme.borderWidth}
            BTN_OUTLINE_OFFSET=-${toString settings.theme.borderWidth}
            " > $out/starlight.colors
            HOME=$out ./change_color.sh -o Starlight -m all -t $out/share/themes $out/starlight.colors
            echo ".termite {
              padding: ${toString ((toPx settings.theme.font.size) / 2)}px;
            }" >> $out/share/themes/Starlight/gtk-3.20/gtk.css
            popd
          '';
        };
      in
      with pkgs; [
        bibata-cursors
        gtk-engine-murrine
        (starlight-oomox-theme)
      ];
  };
}
