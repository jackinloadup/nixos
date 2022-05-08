# This only work on i686-linux and x86_64-linux as far as i know. Maybe i386 as well. unsure about aarch
# isAllowedArch = source: builtins.any (x: source == x) [ "i686-linux" "x86_64-linux" ];
{pkgs, system}:
let
  name = "winbox";
  version = "3.35";
  is64bits = if system == "i686-linux" then false else true;
  source = builtins.fetchurl {
    url = "https://download.mikrotik.com/winbox/${version}/winbox${if is64bits then "64" else ""}.exe";
    sha256 = if is64bits
      then "d24aa8491200aa45d1b91646b19c1401b9a2a721205078128226327589962f4a"
      else "2e6cb5f45cfb7dcdda8b4ca5feb4264335ca8f1a7b62ac8e39967c0137946ca8";
  };
  bin = pkgs.wrapWine {
    inherit is64bits name;
    #firstrunScript = ''
    #  wine ${source}
    #'';
    useDarkTheme = true;
    executable = "${source}";
  };
  desktop = pkgs.makeDesktopItem {
    inherit name;
    desktopName = "WinBox";
    type = "Application";
    exec = "${bin}/bin/winbox";
    icon = builtins.fetchurl {
      url = "https://freesvg.org/img/winbox-mikrotik-icon.png";
      sha256 = "f9c6d413d97330ab7f039783617517e835ef9ceb1adb0987f1f9a2776203aba7";
    };
  };
in pkgs.symlinkJoin {
  inherit name;
  paths = [bin desktop];
}
