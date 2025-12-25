{ config
, pkgs
, nixosConfig
, lib
, ...
}:
let
  inherit (lib) mkIf mkDefault;
  interactive = nixosConfig.programs.zsh.interactiveShellInit;
in
{
  config = mkIf config.programs.zsh.enable {
    home.sessionVariables = {
      _Z_DATA = "${config.home.homeDirectory}/.local/state/z";
    };

    # Needed for vars like XGD_STATE_HOME
    xdg.enable = mkDefault true;


    programs.zsh = {
      autosuggestion.enable = mkDefault false;
      enableCompletion = mkDefault true;
      syntaxHighlighting.enable = mkDefault false;
      #enableVteIntegration = mkDefault true; # adds 300mb
      defaultKeymap = "viins";
      historySubstringSearch.enable = true;

      initContent =
        let
          setWindowTitle = lib.mkOrder 100 ''
            function set_win_title(){
              echo -ne "\033]0; $(basename "$PWD") \007"
            }
            precmd_functions+=(set_win_title)

            ## https://discourse.nixos.org/t/nix-flamegraph-or-profiling-tool/33333/2
            #function nixFunctionCalls {
            #  local WORKDIR=$(mktemp -d /tmp/nix-fun-calls-XXXXX)
            #  nix-instantiate --trace-function-calls "$1" -A "$2" 2> $WORKDIR/nix-function-calls.trace 1>/dev/null
            #  ~/nixgits/nix/contrib/stack-collapse.py $WORKDIR/nix-function-calls.trace > $WORKDIR/nix-function-calls.folded
            #  nix-shell -p flamegraph --run "flamegraph.pl $WORKDIR/nix-function-calls.folded > $WORKDIR/nix-function-calls.svg"
            #  echo "$WORKDIR/nix-function-calls.svg"
            #}
          '';

          interactiveOrder = lib.mkOrder 800 interactive;
        in
        lib.mkMerge [ setWindowTitle interactiveOrder ];

      inherit (nixosConfig.environment) shellAliases;

      loginExtra = ''
        alias -s txt=nvim
        alias -s py=nvim
        alias -s json=jq
      '';

      shellGlobalAliases =
        let
          successSound = "/run/current-system/sw/share/sounds/freedesktop/stereo/complete.oga";
          failureSound = "/run/current-system/sw/share/sounds/freedesktop/stereo/suspend-error.oga";
        in
        {
          UUID = "$(uuidgen | tr -d \\n)";
          G = "| grep";
          L = "| less";
          "@noerr" = "2> /dev/null";
          "@noboth" = "&> /dev/null";
          "@errtostd" = "2&>1";
          # Example: $ long-running-command @notify
          "bell" = "tput bel && sleep 0.1 && tput bel && sleep 0.1 && tput bel";
          "@notify" = "&& pw-play ${successSound} || pw-play ${failureSound}";
        };

      dirHashes = {
        docs = "$HOME/Documents";
        vids = "$HOME/Videos";
        dl = "$HOME/Downloads";
        p = "$HOME/Projects";
      };

      #zsh-autoenv.enable = false;

      history = rec {
        size = 100000;
        save = size;
        path = "$XDG_STATE_HOME/zsh/history";
        #path = "${config.xdg.dataHome}/zsh/history"; # variable isn't available outside HM?
        ignorePatterns = [
          "rm *"
          "pkill *"
          "lscd"
        ];
        expireDuplicatesFirst = true;
        ignoreSpace = true;
      };

      plugins = [
        {
          name = "zsh-z";
          file = "share/zsh-z/zsh-z.plugin.zsh";
          src = pkgs.zsh-z;
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
          };
        }
        #{ # slow
        #  name = "nix-zsh-completions";
        #  file = "nix-zsh-completions.plugin.zsh";
        #  src = pkgs.fetchFromGitHub {
        #    owner = "spwhitt";
        #    repo = "nix-zsh-completions";
        #    rev = "0.4.4";
        #    sha256 = "Djs1oOnzeVAUMrZObNLZ8/5zD7DjW3YK42SWpD2FPNk=";
        #  };
        #}
      ];
    };
  };
}
