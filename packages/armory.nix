# This only work on i686-linux and x86_64-linux as far as i know. Maybe i386 as well. unsure about aarch
# isAllowedArch = source: builtins.any (x: source == x) [ "i686-linux" "x86_64-linux" ];
{pkgs, system}:
let
  source = builtins.fetchFromGitHub {
    owner = "goatpig";
    repo = "BitcoinArmory";
    rev = "v0.96.5";
    sha256 = "ccda21f737deb9a72202eb7890adf399e9111d87f25bdebfa3bd814aade1f1c5";
  };
  bin = pkgs.wrapWine {
    name = "armory";
    #firstrunScript = ''
    #  wine ${source}
    #'';
    executable = "${source}";
  };
  desktop = pkgs.makeDesktopItem {
    name = "armory";
    desktopName = "BitcoinArmory";
    type = "Application";
    exec = "${bin}/bin/armory";
    icon = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/goatpig/BitcoinArmory/master/img/armory_icon_fullres.png";
      sha256 = "f8ab93b12a00e5ff0d24d23fb2dc744d5e703664030d84ef3ead3fcd53854487";
    };
  };
in pkgs.symlinkJoin {
  name = "armory";
  paths = [bin desktop];
}
