{
  user = {
    name = "Lucas Riutzel";
    uid = 1000;
    email = "lriutzel@gmail.com";
    username = "lriutzel";
    historySize = 2000; # used for zsh history atm
    langCode = "en";
    locale = "en_US";
    characterSet = "UTF-8";
  };

  home = {
    domain = "home.lucasr.com";
    name = "Starbase";
    latitude = "36.629727";
    longitude = "-93.216178";
    elevation = 70; # in meters = 230ft
    unit_system = "imperial";
    timezone = "America/Chicago";
    currency = "USD";
  };

  timeouts = { 
    show_age_after = 60;
    idle = 150;
    screenLock = 300;
    displayOff = 330;
  };

  theme = {
    background_opacity = 0.95;
    cursor = {
      #package = pkgs.quintom-cursor-theme;
      name = "Quintom_Ink";
      size = 32;
    };
    gtk = {
      name = "gruvbox-dark";
      package = "gruvbox-dark-gtk";
    };
    borderWidth = 2;
    font = {
      serif = {
        family = "DejaVu Serif";
        style = "Regular";
      };
      normal = {
        family = "Lato";
        style = "Regular";
      };
      mono = {
        family = "DroidSansMono Nerd Font Mono";
        style = "Regular";
      };
      emoji = {
        family = "Noto Color Emoji";
        style = "Regular";
      };
      console = "Lat2-Terminus16";
      size = 10;
    };
    base16 = {
      scheme = "gruvbox";
      variant = "gruvbox-dark-hard";
      #scheme = "tomorrow";
      #variant = "tomorrow-night";
      #scheme = "woodland";
      #variant = "woodland";
    };
  };
}

###############
# User settings
###############
# name
# email
# username
# groups
# hashedpassword?
# gui themes/fonts
# console themes/fonts for user
# gui setup and configs
# suppliment vpn
# smartcard?
# gnupgp
# user application categories (mvp, debug, desktop, browsers, ect);

###############
# Machine settings
###############
# timezone
# hostname
# drive settings / encryption
# system application categories (mvp,debug{usbutils,pciutils,ect},compile?)
# system application configuration
# basic editor vim with sane settings
# console themes/fonts
# audio devices names via pipewire/alsa-monitor
# system backlight management (ddccontrol/light)
# hibernation support
# root user reference
# which additional users to load
# ssh
# wireguard / vpn
# smartcard?
# printing/scanning
# physical monitor arangement?
# power and fan control
