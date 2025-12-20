{ config
, pkgs
, lib
, inputs
, ...
}:
let
  inherit (lib) mkIf optionalString;
in
{
  config = mkIf config.programs.bash.enable {
    programs.bash = {
      historyFile = "~/.local/state/bash/history";
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
      historyIgnore = [ "l" "ll" "lll" "bg" "fg" "clear" "ls" "cd" "exit" ];
      initExtra =
        ''
        ''
        + optionalString config.programs.starship.enable ''
          eval "$(starship init bash)"
        '';
      shellOptions = [
        "dirspell"
        "cdspell"
        "histappend"
        "cmdhist"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
      ];
    };
  };
}
