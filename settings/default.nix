{
  timezone = "America/Chicago";

  user = {
    name = "Lucas Riutzel";
    uid = 1000;
    email = "lriutzel@gmail.com";
    username = "lriutzel";
  };

  security = {
    timeouts = { # screensaver timeout then lock after
      screenLock = "300";
      displayOff = "330";
    };
  };

  theme = {
    background_opacity = 0.95;
    gtk = "Adwaita";
    font = {
      normal = {
        family = "FiraCode Nerd Font";
        style = "Regular";
      };
      mono = {
        family = "FiraCode Nerd Font";
        style = "Regular";
      };
      size = 12;
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
