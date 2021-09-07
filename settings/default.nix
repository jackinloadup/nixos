{
  timezone = "America/Chicago";

  user = {
    name = "Lucas Riutzel";
    email = "lriutzel@gmail.com";
    username = "lriutzel";
  };

  security = {
    timeouts = { # screensaver timeout then lock after
      screenLock = "300";
      displayOff = "60";
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
