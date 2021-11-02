{pkgs}:
let
  source = builtins.fetchurl {
    url = "https://download.mikrotik.com/winbox/3.31/winbox.exe";
    sha256 = "cb22a2539c49969fd541562e5fbf6974212f7badf2577494ce2fbf73dd798007";
  };
  bin = pkgs.wrapWine {
    name = "winbox";
    #firstrunScript = ''
    #  wine ${source}
    #'';
    executable = "${source}";
  };
  desktop = pkgs.makeDesktopItem {
    name = "winbox";
    desktopName = "WinBox";
    type = "Application";
    exec = "${bin}/bin/winbox";
    icon = builtins.fetchurl {
      url = "https://freesvg.org/img/winbox-mikrotik-icon.png";
      sha256 = "f9c6d413d97330ab7f039783617517e835ef9ceb1adb0987f1f9a2776203aba7";
    };
  };
in pkgs.symlinkJoin {
  name = "winbox";
  paths = [bin desktop];
}
# dark theme https://gist.github.com/Zeinok/ceaf6ff204792dde0ae31e0199d89398
# plus wine-breeze-dark.reg
