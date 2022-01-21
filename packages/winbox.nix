# This only work on i686-linux and x86_64-linux as far as i know. Maybe i386 as well. unsure about aarch
# isAllowedArch = source: builtins.any (x: source == x) [ "i686-linux" "x86_64-linux" ];
{pkgs, system}:
let
  is64bits = if system == "i686-linux" then false else true;
  source = builtins.fetchurl {
    url = "https://download.mikrotik.com/winbox/3.32/winbox${if is64bits then "64" else ""}.exe";
    sha256 = if is64bits
      then
        "d67e92155f1558bf5946c009c9b05c8336ca5ffc16f0621d02d741456cfbc0bd"
      else
        "07322be03e3b272d9af2cde87d6bb6baa001b9e30413e8740a6af178b65d35a3";
  };
  source64 = builtins.fetchurl {
    url = "https://download.mikrotik.com/winbox/3.32/winbox64.exe";
    sha256 = "d67e92155f1558bf5946c009c9b05c8336ca5ffc16f0621d02d741456cfbc0bd";
  };
  bin = pkgs.wrapWine {
    name = "winbox";
    #firstrunScript = ''
    #  wine ${source}
    #'';
    useDarkTheme = true;
    is64bits = if system == "i686-linux" then false else true;
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
