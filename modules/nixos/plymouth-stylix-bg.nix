# Custom Plymouth theme that uses stylix.image as background
{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption types;

  # Get stylix config
  stylixCfg = config.stylix;
  plymouthCfg = stylixCfg.targets.plymouth;
  inherit (config.lib.stylix) colors;
  inherit (plymouthCfg) showLogo;
  foregroundColor = "${colors.base05-dec-r}, ${colors.base05-dec-g}, ${colors.base05-dec-b}"; # blue accent  # progress bar background

  # Hex colors for ImageMagick
  accentColorHex = "#${colors.base0D}";
  dimColorHex = "#${colors.base01}";

  themeScript = builtins.toFile "stylix-bg-plymouth-theme" ''
    center_x = Window.GetWidth() / 2;
    center_y = Window.GetHeight() / 2;
    baseline_y = Window.GetHeight() * 0.9;
    message_y = Window.GetHeight() * 0.75;

    ### BACKGROUND IMAGE ###

    background.image = Image("background.png");
    background.sprite = Sprite(background.image);

    # Scale to fill screen
    screen_w = Window.GetWidth();
    screen_h = Window.GetHeight();
    img_w = background.image.GetWidth();
    img_h = background.image.GetHeight();

    scale_x = screen_w / img_w;
    scale_y = screen_h / img_h;

    # Use the larger scale to cover the entire screen (cover mode)
    if (scale_x > scale_y) {
      scale = scale_x;
    } else {
      scale = scale_y;
    }

    scaled_img = background.image.Scale(img_w * scale, img_h * scale);
    background.sprite.SetImage(scaled_img);

    # Center the scaled image
    background.sprite.SetPosition(
      (screen_w - (img_w * scale)) / 2,
      (screen_h - (img_h * scale)) / 2,
      0
    );

    ${lib.optionalString showLogo ''
    ### LOGO ###

    logo.image = Image("logo.png");
    logo.sprite = Sprite(logo.image);
    logo.sprite.SetPosition(
      center_x - (logo.image.GetWidth() / 2),
      center_y - (logo.image.GetHeight() / 2),
      1
    );

    ${lib.optionalString plymouthCfg.logoAnimated ''
    logo.spinner_active = 1;
    logo.spinner_third = 0;
    logo.spinner_index = 0;
    logo.spinner_max_third = 32;
    logo.spinner_max = logo.spinner_max_third * 3;

    real_index = 0;
    for (third = 0; third < 3; third++) {
      for (index = 0; index < logo.spinner_max_third; index++) {
        subthird = index / logo.spinner_max_third;
        angle = (third + ((Math.Sin(Math.Pi * (subthird - 0.5)) / 2) + 0.5)) / 3;
        logo.spinner_image[real_index] = logo.image.Rotate(2*Math.Pi * angle);
        real_index++;
      }
    }

    fun activate_spinner () {
      logo.spinner_active = 1;
    }

    fun deactivate_spinner () {
      logo.spinner_active = 0;
      logo.sprite.SetImage(logo.image);
    }

    fun refresh_callback () {
      if (logo.spinner_active) {
        logo.spinner_index = (logo.spinner_index + 1) % (logo.spinner_max * 2);
        logo.sprite.SetImage(logo.spinner_image[Math.Int(logo.spinner_index / 2)]);
      }
    }

    Plymouth.SetRefreshFunction(refresh_callback);
    ''}
    ''}

    ### PROGRESS BAR ###

    progress_bar.original_image = Image("progress-bar.png");
    progress_bar.bg_image = Image("progress-bg.png");

    progress_bar.x = center_x - (progress_bar.bg_image.GetWidth() / 2);
    progress_bar.y = Window.GetHeight() * 0.75;

    # Background bar
    progress_bar.bg_sprite = Sprite(progress_bar.bg_image);
    progress_bar.bg_sprite.SetPosition(progress_bar.x, progress_bar.y, 1);

    # Progress fill
    progress_bar.sprite = Sprite();
    progress_bar.sprite.SetPosition(progress_bar.x, progress_bar.y, 2);

    fun boot_progress_callback(duration, progress) {
      # Scale progress since script-based themes often only reach ~0.30
      scaled_progress = Math.Min(progress * 3.3, 1.0);
      new_width = Math.Int(progress_bar.original_image.GetWidth() * scaled_progress);

      if (new_width > 1) {
        progress_bar.image = progress_bar.original_image.Scale(new_width, progress_bar.original_image.GetHeight());
        progress_bar.sprite.SetImage(progress_bar.image);
      }
    }

    Plymouth.SetBootProgressFunction(boot_progress_callback);

    ### PASSWORD ###

    prompt = null;
    bullets = null;
    bullet.image = Image.Text("•", ${foregroundColor});

    fun password_callback (prompt_text, bullet_count) {
      ${lib.optionalString (showLogo && plymouthCfg.logoAnimated) "deactivate_spinner();"}

      # Hide progress bar during password entry
      progress_bar.bg_sprite.SetOpacity(0);
      progress_bar.sprite.SetOpacity(0);

      prompt.image = Image.Text(prompt_text, ${foregroundColor});
      prompt.sprite = Sprite(prompt.image);
      prompt.sprite.SetPosition(
        center_x - (prompt.image.GetWidth() / 2),
        baseline_y - prompt.image.GetHeight(),
        2
      );

      total_width = bullet_count * bullet.image.GetWidth();
      start_x = center_x - (total_width / 2);

      bullets = null;
      for (i = 0; i < bullet_count; i++) {
          bullets[i].sprite = Sprite(bullet.image);
          bullets[i].sprite.SetPosition(
            start_x + (i * bullet.image.GetWidth()),
            baseline_y + bullet.image.GetHeight(),
            2
          );
      }
    }

    Plymouth.SetDisplayPasswordFunction(password_callback);

    ### QUESTION ###

    question = null;
    answer = null;

    fun question_callback(prompt_text, entry) {
        ${lib.optionalString (showLogo && plymouthCfg.logoAnimated) "deactivate_spinner();"}

        # Hide progress bar during question
        progress_bar.bg_sprite.SetOpacity(0);
        progress_bar.sprite.SetOpacity(0);

        question = null;
        answer = null;

        question.image = Image.Text(prompt_text, ${foregroundColor});
        question.sprite = Sprite(question.image);
        question.sprite.SetPosition(
            center_x - (question.image.GetWidth() / 2),
            baseline_y - question.image.GetHeight(),
            2
        );

        answer.image = Image.Text(entry, ${foregroundColor});
        answer.sprite = Sprite(answer.image);
        answer.sprite.SetPosition(
            center_x - (answer.image.GetWidth() / 2),
            baseline_y + answer.image.GetHeight(),
            2
        );
    }

    Plymouth.SetDisplayQuestionFunction(question_callback);

    ### MESSAGE ###

    message = null;

    fun message_callback(text) {
        message.image = Image.Text(text, ${foregroundColor});
        message.sprite = Sprite(message.image);
        message.sprite.SetPosition(
            center_x - message.image.GetWidth() / 2,
            message_y,
            2
        );
    }

    Plymouth.SetMessageFunction(message_callback);

    ### NORMAL ###

    fun normal_callback() {
        prompt = null;
        bullets = null;

        question = null;
        answer = null;

        message = null;

        # Show progress bar again
        progress_bar.bg_sprite.SetOpacity(1);
        progress_bar.sprite.SetOpacity(1);

        ${lib.optionalString (showLogo && plymouthCfg.logoAnimated) "activate_spinner();"}
    }

    Plymouth.SetDisplayNormalFunction(normal_callback);

    ### QUIT ###

    fun quit_callback() {
      prompt = null;
      bullets = null;
      ${lib.optionalString (showLogo && plymouthCfg.logoAnimated) "deactivate_spinner();"}
    }

    Plymouth.SetQuitFunction(quit_callback);
  '';

  theme = pkgs.runCommand "stylix-bg-plymouth" { } ''
        themeDir="$out/share/plymouth/themes/stylix-bg"
        mkdir -p $themeDir

        # Process background image
        ${lib.getExe' pkgs.imagemagick "convert"} \
          ${stylixCfg.image} \
          $themeDir/background.png

        ${lib.optionalString showLogo ''
        # Process logo with transparent border for rotation
        ${lib.getExe' pkgs.imagemagick "convert"} \
          -background transparent \
          -bordercolor transparent \
          ${lib.optionalString plymouthCfg.logoAnimated "-border 42%"} \
          ${plymouthCfg.logo} \
          $themeDir/logo.png
        ''}

        # Generate progress bar images (400x8 pixels)
        ${lib.getExe' pkgs.imagemagick "convert"} \
          -size 400x8 \
          "xc:${dimColorHex}" \
          -alpha set -channel A -evaluate set 50% \
          $themeDir/progress-bg.png

        ${lib.getExe' pkgs.imagemagick "convert"} \
          -size 400x8 \
          "xc:${accentColorHex}" \
          $themeDir/progress-bar.png

        cp ${themeScript} $themeDir/stylix-bg.script

        cat > $themeDir/stylix-bg.plymouth << 'EOF'
    [Plymouth Theme]
    Name=Stylix Background
    ModuleName=script

    [script]
    ImageDir=$themeDir
    ScriptFile=$themeDir/stylix-bg.script
    EOF

        # Substitute the actual path
        substituteInPlace $themeDir/stylix-bg.plymouth --replace-quiet '$themeDir' "$themeDir"
  '';
in
{
  options.stylix.targets.plymouth.showLogo = mkOption {
    type = types.bool;
    default = true;
    description = "Whether to show the logo on the boot screen.";
  };

  config = {
    # Disable stylix's default plymouth target to avoid conflicts
    stylix.targets.plymouth.enable = false;

    boot.plymouth.themePackages = [ theme ];
  };
}
