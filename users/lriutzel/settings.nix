{
  name = "Lucas Riutzel";
  uid = 1000;
  email = "lriutzel@gmail.com";
  username = "lriutzel";
  historySize = 2000; # used for zsh history atm. maybe not
  locale = "en_US";
  characterSet = "UTF-8";
  home = "Starbase";

  theme = {
    background_opacity = 0.95;
    borderWidth = 2;

    gtk = {
      name = "gruvbox-dark";
      package = "gruvbox-dark-gtk";
    };

    font = {
      normal = {
        family = "Lato";
        style = "Regular";
      };
      mono = {
        family = "DroidSansMono Nerd Font Mono";
        style = "Regular";
      };
      size = 12;
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
