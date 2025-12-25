{ pkgs, ... }: {
  bars = [
    {
      command = "${pkgs.waybar}/bin/waybar";
      position = "top";
      #fonts = fontConf;
      trayOutput = "*";
    }
  ];
}
