{pkgs}:
let
  source = builtins.fetchurl {
    url = "https://download.mikrotik.com/winbox/3.32/winbox.exe";
    sha256 = "07322be03e3b272d9af2cde87d6bb6baa001b9e30413e8740a6af178b65d35a3";
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
# @TODO figure out how to add dark themes into wine
# dark theme https://gist.github.com/Zeinok/ceaf6ff204792dde0ae31e0199d89398
# plus wine-breeze-dark.reg
