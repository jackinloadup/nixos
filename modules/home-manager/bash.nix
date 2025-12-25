{ config
, lib
, ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.programs.bash.enable {
    programs.bash = {
      historyFile = "$XDG_STATE_HOME/bash/history";
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
      historyIgnore = [ "l" "ll" "lll" "bg" "fg" "clear" "ls" "cd" "exit" ];
      initExtra =
        ''
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
