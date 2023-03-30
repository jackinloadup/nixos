{ config, pkgs, nixosConfig, lib, inputs, ... }:

let
  inherit (lib) concatStrings mkDefault optionals;
  settings = import ../settings;
  sizeTarget = nixosConfig.machine.sizeTarget;
  ifTui = sizeTarget > 0;
  ifGraphical = sizeTarget > 1;
  interactive = nixosConfig.programs.zsh.interactiveShellInit;
in {
  imports = [];
  config = {
    programs = {
      zsh = {
        enable = true;
        enableAutosuggestions = ifTui;
        enableCompletion = ifTui;

        initExtra = ''
          function set_win_title(){
            echo -ne "\033]0; $(basename "$PWD") \007"
          }
          precmd_functions+=(set_win_title)

          '' + optionals ifTui ''
          eval "$(starship init zsh)"
          '' + interactive;

        shellAliases = nixosConfig.environment.shellAliases;

        loginExtra = ''
        '';

        shellGlobalAliases = {
          UUID = "$(uuidgen | tr -d \\n)";
          G = "| grep";
          L = "| less";
          "@noerr" = "2> /dev/null";
          "@noboth" = "&> /dev/null";
          "@errtostd" = "2&>1";
        };

        dirHashes = {
          docs  = "$HOME/Documents";
          vids  = "$HOME/Videos";
          dl    = "$HOME/Downloads";
          p     = "$HOME/Projects";
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
        ];
      };

      starship = {
        enable = mkDefault ifTui;
        package = pkgs.unstable.starship;
        enableBashIntegration = true;
        enableZshIntegration = true;
        settings = {
          format = concatStrings [
            "$time"
            "$username"
            "$hostname"
            "$character"
          ];
          right_format = concatStrings [
            "$all"
          ];
          scan_timeout = 10;
          add_newline = false;
          line_break = {
            disabled = true;
          };
          time = {
            disabled = false;
            time_format = "%l:%M%p";
            utc_time_offset = "-5";
            format = "$time($style) ";
          };
          username = {
            disabled = false;
          };
          aws = { 
            format = "on [$symbol($profile )(\($region\) )]($style)";
            style = "bold blue";
            symbol = "🅰 ";
            region_aliases = {
              us-east-1 = "va";
              us-west-1 = "utah";
            };
            profile_aliases = {
              CompanyGroupFrobozzOnCallAccess = "Frobozz";
            };
          };
        };
      };
    };
  };
}
