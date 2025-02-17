{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) attrNames mkIf mkOption mkForce types;
  inherit (lib.strings) concatStringsSep;
  normalUsers = attrNames config.home-manager.users;
in {
  imports = [];

  config = mkIf config.services.xserver.displayManager.gdm.enable {
    #programs.dconf.enable = true;

    # gnome has its own power management tool
    services.tlp.enable = mkForce false;

    services.xserver.enable = true;
    programs.xwayland.enable = true;
    #services.xserver.autorun = true;
    #services.xserver.displayManager.lightdm.enable = false;
    services.xserver.displayManager.gdm.settings = {
      greeter = {
        #IncludeAll = true;
        Include = concatStringsSep "," normalUsers;
      };
    };
    services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      [com.ubuntu.login-screen]
      background-repeat='no-repeat'
      background-size='cover'
      background-color='#e51fab'
    '';

    # fixed issue where user would be pulled back to the login screen
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    # https://discourse.nixos.org/t/unable-to-change-background-in-gdm/33563/5
    nixpkgs = {
      overlays = [
        (self: super: {
          #gnome = super.gnome.overrideScope' (selfg: superg: {
            gnome-shell = super.gnome-shell.overrideAttrs (old: {
              patches = (old.patches or []) ++ [
                (let
                  #bg = pkgs.fetchurl {
                  #  url = "https://orig00.deviantart.net/0054/f/2015/129/b/9/reflection_by_yuumei-d8sqdu2.jpg";
                  #  sha256 = "0f0vlmdj5wcsn20qg79ir5cmpmz5pysypw6a711dbaz2r9x1c79l";
                  #};
                  bg = "${pkgs.gnome-backgrounds}/share/backgrounds/gnome/blobs-d.svg";
                in pkgs.writeText "bg.patch" ''
                  --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                  +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                  @@ -15,4 +15,5 @@ $_gdm_dialog_width: 23em;
                   /* Login Dialog */
                   .login-dialog {
                     background-color: $_gdm_bg;
                  +  background-image: url('file://${bg}');
                   }
                '')
              ];
            #});
          });
        })
      ];
    };
  };
}
