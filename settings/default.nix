let
  colors = import ./colors;
in {
  timezone = "America/Chicago";

  colorscheme = colors.dark;

  user = {
    name = "Lucas Riutzel";
    email = "lriutzel@gmail.com";
    username = "lriutzel";
  };
}
