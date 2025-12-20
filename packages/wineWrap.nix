# @TODO dark theme could be maybe detected and switched at runtime based on gtk theme or similar?
with builtins;
{ pkgs
, lib
,
}: { is64bits ? if system == "i686-linux"
     then false
     else true
   , winePackage ? "minimal"
   , # could also be base, full, stableFull
     wineFlags ? ""
   , useDarkTheme ? false
   , executable
   , chdir ? null
   , name
   , tricks ? [ ]
   , useGecko ? false
   , useMono ? false
   , setupScript ? ""
   , firstrunScript ? ""
   , home ? ""
   ,
   }:
let
  inherit (lib) makeBinPath;
  inherit (lib.lists) remove;
  inherit (lib.strings) concatStringsSep;

  pkgGroup =
    if is64bits
    then "wine64Packages"
    else "winePackages";

  pkg = pkgs.${pkgGroup}.${winePackage};

  bin =
    if is64bits
    then "${pkg}/bin/wine64"
    else "${pkg}/bin/wine";

  # only adds paths. doesn't actually install
  requiredPackages = with pkgs; [
    pkg
    winetricks
    cabextract
  ];
  WINENIX_PROFILES = "$XDG_DATA_HOME/wine-nix-profiles";
  WINE_NIX = "$XDG_CACHE_HOME/wine${
      if is64bits
      then "64"
      else "32"
    }-nix";
  PATH = makeBinPath requiredPackages;
  NAME = name;
  HOME =
    if home == ""
    then "${WINENIX_PROFILES}/${name}"
    else home;
  WINEARCH =
    if is64bits
    then "win64"
    else "win32";
  # Don't ask user at setup about installing gecko or mono if not needed
  DLLOVERRIDES =
    if !useGecko || !useMono
    then
      let
        overridesRaw = remove "" [
          (
            if !useGecko
            then "mshtml"
            else ""
          )
          (
            if !useMono
            then "mscoree"
            else ""
          )
        ];
      in
      concatStringsSep "," overridesRaw + "="
    else "";
  setupHook = ''
    WINEDLLOVERRIDES="${DLLOVERRIDES}" ${pkg}/bin/wineboot
  '';
  tricksHook =
    if (length tricks) > 0
    then
      let
        tricksStr = concatStringsSep " " tricks;
      in
      "${pkgs.winetricks}/bin/winetricks ${tricksStr}"
    else "";
  darkReg = pkgs.writeTextFile {
    name = "wine-breeze-dark.reg";
    text = builtins.readFile ./wine-breeze-dark.reg;
  };
  setupDarkTheme =
    if useDarkTheme
    then "${bin} start regedit.exe ${darkReg}"
    else "";

  script = pkgs.writeShellScriptBin name ''
    export APP_NAME="${NAME}"
    export WINEARCH=${WINEARCH}
    export WINE_NIX="${WINE_NIX}"
    export WINE_NIX_PROFILES="${WINENIX_PROFILES}"
    export PATH=$PATH:${PATH}
    export HOME="${HOME}"
    mkdir -p "$HOME"
    export WINEPREFIX="$WINE_NIX/${name}"
    export EXECUTABLE="${executable}"
    mkdir -p "$WINE_NIX" "$WINE_NIX_PROFILES"
    ${setupScript}
    if [ ! -d "$WINEPREFIX" ] # if the prefix does not exist
    then
      ${setupHook}
      # ${bin} cmd /c dir > /dev/null 2> /dev/null # initialize prefix
      wineserver -w
      ${tricksHook}
      ${firstrunScript}
      ${setupDarkTheme}
      rm "$WINEPREFIX/drive_c/users/$USER" -rf
      ln -s "$HOME" "$WINEPREFIX/drive_c/users/$USER"
    fi
    ${
      if chdir != null
      then ''cd "${chdir}"''
      else ""
    }
    if [ ! "$REPL" == "" ]; # if $REPL is setup then start a shell in the context
    then
      bash
      exit 0
    fi

    ${bin} ${wineFlags} "$EXECUTABLE" "$@"
    wineserver -w
  '';
in
script
