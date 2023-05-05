# This only work on i686-linux and x86_64-linux as far as i know. Maybe i386 as well. unsure about aarch
# isAllowedArch = source: builtins.any (x: source == x) [ "i686-linux" "x86_64-linux" ];
{
  pkgs,
  system,
}: let
  name = "winbox";
  version = "3.37";
  is64bits =
    if system == "i686-linux"
    then false
    else true;
  source = builtins.fetchurl {
    url = "https://download.mikrotik.com/winbox/${version}/winbox${
      if is64bits
      then "64"
      else ""
    }.exe";
    sha256 =
      if is64bits
      then "abe696e45809f26b0320926a0014d3088dcc5ac43d553a2b7a4e25f54a047439"
      else "94336289cf2e1de339b75d6a799a7855eabbe55bc1b9b4dd2bbd94c316188afe";
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
in
  pkgs.symlinkJoin {
    inherit name;
    paths = [bin desktop];
  }
