# TODO install mono and gecko if needed instead of prompting at runtime

# @NOTE dark theme could be maybe detected and switched at runtime based on gtk theme or similar?
with builtins;
{ pkgs }:
{ 
  is64bits ? false
, wine ? if is64bits then pkgs.wineWowPackages.stable else pkgs.wine
, wineFlags ? ""
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
}:
let
  wineBin = "${wine}/bin/wine${if is64bits then "64" else ""}";
  # only adds paths. doesn't actually install
  requiredPackages = with pkgs; [
    wine
    winetricks
    cabextract
    wineWowPackages.stable
  ];
  WINENIX_PROFILES = "$HOME/WINENIX_PROFILES";
  # define antes de definir $HOME senão ele vai gravar na nova $HOME a .wine-nix
  WINE_NIX="$HOME/.wine${if is64bits then "64" else "32"}-nix";
  PATH = pkgs.lib.makeBinPath requiredPackages;
  NAME = name;
  HOME = if home == "" 
    then "${WINENIX_PROFILES}/${name}" 
    else home;
  WINEARCH = if is64bits 
    then "win64" 
    else "win32";
  # Don't ask user at setup about installing gecko or mono if not needed
  DLLOVERRIDES = if !useGecko || !useMono then
    let
      overridesRaw = pkgs.lib.lists.remove "" [
        (if !useGecko then "mshtml" else "")
        (if !useMono then "mscoree" else "")
      ];
      overrides = pkgs.lib.strings.concatStringsSep "," overridesRaw + "=";
    in overrides
    else "";
  setupHook = ''
    WINEDLLOVERRIDES="${DLLOVERRIDES}" ${wine}/bin/wineboot
  '';
  tricksHook = if (length tricks) > 0 then
      let
        tricksStr = concatStringsSep " " tricks;
        tricksCmd = "${pkgs.winetricks}/bin/winetricks ${tricksStr}";
      in tricksCmd
    else "";
  darkReg = pkgs.writeTextFile {
    name = "wine-breeze-dark.reg";
    text = builtins.readFile ./wine-breeze-dark.reg;
  };
  setupDarkTheme = if useDarkTheme then ''
      ${wineBin} start regedit.exe ${darkReg}
  '' else "";

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
      # ${wineBin} cmd /c dir > /dev/null 2> /dev/null # initialize prefix
      wineserver -w
      ${tricksHook}
      ${firstrunScript}
      ${setupDarkTheme}
      rm "$WINEPREFIX/drive_c/users/$USER" -rf
      ln -s "$HOME" "$WINEPREFIX/drive_c/users/$USER"
    fi
    ${if chdir != null 
      then ''cd "${chdir}"'' 
      else ""}
    if [ ! "$REPL" == "" ]; # if $REPL is setup then start a shell in the context
    then
      bash
      exit 0
    fi

    ${wineBin} ${wineFlags} "$EXECUTABLE" "$@"
    wineserver -w
  '';
in script
