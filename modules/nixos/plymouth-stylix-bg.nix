# Custom Plymouth theme using two-step module with stylix.image as background
# Uses circle/dots spinner for accurate progress reporting
{ lib, pkgs, config, ... }:
let

  # Get stylix config
  stylixCfg = config.stylix;
  inherit (config.lib.stylix) colors;

  # Hex colors for two-step config (0xRRGGBB format, no # prefix)
  bgColorHex = colors.base00;
  progressBgHex = colors.base01;
  progressFgHex = colors.base0D;

  # Source for spinner theme assets (circle/dots style)
  spinnerDir = "${pkgs.plymouth}/share/plymouth/themes/spinner";

  theme = pkgs.runCommand "stylix-spinfinity-plymouth" { } ''
        themeDir="$out/share/plymouth/themes/stylix-spinfinity"
        mkdir -p $themeDir

        # Scale Stylix background image to 1920x1080 (cover mode) as watermark
        ${lib.getExe' pkgs.imagemagick "convert"} \
          ${stylixCfg.image} \
          -resize 1920x1080^ \
          -gravity center \
          -extent 1920x1080 \
          $themeDir/watermark.png

        # Copy spinner throbber animation frames (0001-0030, circle/dots style)
        for i in $(seq -f '%04g' 1 30); do
          cp ${spinnerDir}/throbber-$i.png $themeDir/
        done

        # Copy animation frames
        for i in $(seq -f '%04g' 1 36); do
          cp ${spinnerDir}/animation-$i.png $themeDir/
        done

        # Copy UI images for password/question dialogs
        cp ${spinnerDir}/bullet.png $themeDir/
        cp ${spinnerDir}/entry.png $themeDir/
        cp ${spinnerDir}/lock.png $themeDir/
        cp ${spinnerDir}/capslock.png $themeDir/
        cp ${spinnerDir}/keyboard.png $themeDir/
        cp ${spinnerDir}/keymap-render.png $themeDir/

        # Create the plymouth config file
        cat > $themeDir/stylix-spinfinity.plymouth << 'EOF'
    [Plymouth Theme]
    Name=Stylix Spinner
    Description=Circle spinner with Stylix background image
    ModuleName=two-step

    [two-step]
    ImageDir=THEME_DIR_PLACEHOLDER
    Font=DejaVu Sans 12
    TitleFont=DejaVu Sans 30
    BackgroundStartColor=0x${bgColorHex}
    BackgroundEndColor=0x${bgColorHex}
    HorizontalAlignment=.5
    VerticalAlignment=.55
    WatermarkHorizontalAlignment=.5
    WatermarkVerticalAlignment=.5
    ProgressBarHorizontalAlignment=.5
    ProgressBarVerticalAlignment=.9
    ProgressBarWidth=400
    ProgressBarHeight=8
    ProgressBarBackgroundColor=0x${progressBgHex}80
    ProgressBarForegroundColor=0x${progressFgHex}ff

    [boot-up]
    UseProgressBar=true
    UseAnimation=true

    [shutdown]
    UseProgressBar=false
    UseAnimation=false

    [reboot]
    UseProgressBar=false
    UseAnimation=false

    [updates]
    UseProgressBar=true
    UseAnimation=true
    SuppressMessages=true
    ProgressBarShowPercentComplete=true
    Title=Installing Updates...
    SubTitle=Do not turn off your computer

    [system-upgrade]
    UseProgressBar=true
    UseAnimation=true
    SuppressMessages=true
    ProgressBarShowPercentComplete=true
    Title=Upgrading System...
    SubTitle=Do not turn off your computer

    [firmware-upgrade]
    UseProgressBar=true
    UseAnimation=true
    SuppressMessages=true
    ProgressBarShowPercentComplete=true
    Title=Upgrading Firmware...
    SubTitle=Do not turn off your computer
    EOF

        # Substitute the placeholder with actual theme directory
        substituteInPlace $themeDir/stylix-spinfinity.plymouth \
          --replace-quiet 'THEME_DIR_PLACEHOLDER' "$themeDir"
  '';
in
{
  config = {
    # Disable stylix's default plymouth target to avoid conflicts
    stylix.targets.plymouth.enable = false;

    boot.plymouth = {
      # define in quietBoot.nix
      #theme = "stylix-spinfinity";
      themePackages = [ theme ];
    };
  };
}
