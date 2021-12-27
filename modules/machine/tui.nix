{ lib, pkgs, config, inputs, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    inputs.base16.hmModule
  ];
  options.machine.tui = mkEnableOption "Hide boot log from tui/gui";

  config = mkIf cfg.tui {
    environment.systemPackages = with pkgs; [
      pv # progress meter

      #vim # text editor
      neovim # text editor

      git # source code manager

      tmux # terminal multiplexer
      #tmux-cssh

      #ncpamixer # couldn't get it to work

      #vlock # tty/vtty locker
      # fasd # quick access to files and dir

      exa # ls replacement
      jq # json parsing
      tree # file/directory viewer in tree format
      ripgrep # grep alternative
      rsync
      pass # password manager
      lf # file manager
    #  highlight # highlight files for previews
    #  poppler_utils # for pdf2text
      bat # cat alternative
      viu # terminal image viewer

      ## compression tools
      unzip
      #unrar #unfree
      p7zip

      ## http/web
      lynx # text web browser
      wget # http client
      curl # http client

      # Debug
      ## hardware
      pciutils
      powertop

      ## network
      iftop
      latencytop
      jnettop
      dnstop
      mtr # traceroute and ping

      ## io
      iotop
      input-utils # lsinput

      ## files
      lsof
      ncdu # ncurses disk usage viewer
      file
      fd # find alternative

      ## OS (nix/linux)
      nix-tree # A terminal curses application to browse a Nix store paths dependencies
      vulnix # vulnerability scanner for nix
      # atop?
      htop # process, cpu, memory viewer
    ];

    themes.base16 = with settings.theme; {
      enable = true;
      scheme = base16.scheme;
      variant = base16.variant;
      defaultTemplateType = "default";
      # Add extra variables for inclusion in custom templates
      # not sure the "extraParams" are being used. No custom templates afaik
      extraParams = {
        fontName = font.mono.family;
        fontSize = font.size;
      };
    };


    console = {
      earlySetup = mkDefault true;
      font = "Lat2-Terminus16";
      keyMap = "us";
      colors = with config.lib.base16.theme; [
        base00-hex # 0 bg
        base08-hex # 1 red
        base0B-hex # 2 green
        base0A-hex # 3 yellow
        base0D-hex # 4 blue
        base0E-hex # 5 violet
        base0C-hex # 6 cyan
        base05-hex # 7 gray/dim
        base03-hex # 8 fg
        base08-hex # 9 bright red
        base0B-hex # 10 bright green
        base0A-hex # 11 bright yellow
        base0D-hex # 12 bright blue
        base0E-hex # 13 bright violet
        base0C-hex # 14 bright cyan
        base07-hex # 15 fg 2
      ];
    };

    #programs.autojump.enable = true;
    programs.bash = {
      interactiveShellInit = ''
        source ${config.lib.base16.templateFile { name = "shell"; }}
      '';
    };

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true; #TODO limit to authorized keys only
      startWhenNeeded = true;
    };

    services.sshguard = {
      enable = true;
      detection_time = 3600;
    };

    environment.sessionVariables = {
      EDITOR = "vim";
    };

    environment.shellAliases = {
      ".." = "cd ..";
      "ncdu" = "ncdu --color dark";
      "nixos-current-repl" = "source /etc/set-environment && nix repl $(echo $NIX_PATH | perl -pe 's|.*(/nix/store/.*-source/repl.nix).*|\\1|')";
    };

    programs.less = {
      enable = true;
      #configFile = {
      #};
    };

    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      newSession = true;
      extraConfig = ''
        set -ga terminal-overrides ',*256col*:Tc'
        source ${config.lib.base16.templateFile { name="tmux"; }}
      '';
    };
    environment.etc."lf/lfrc".text = ''
set previewer /etc/lf/pv.sh
map i $LESSOPEN='| /etc/lf/pv.sh %s' less -R $f
cmd open ''${{
    case $(file --mime-type $f -b) in
        text/*) vi $fx;;
        image/*) imv $fx;;
        *) for f in $fx; do xdg-open $f > /dev/null 2> /dev/null & done;;
    esac
}}
      '';
    environment.etc."lf/pv.sh".mode = "0755";
    environment.etc."lf/pv.sh".text = ''
#!/bin/sh

case "$1" in
    *.tar*) tar tf "$1";;
    *.zip) unzip -l "$1";;
    *.rar) unrar l "$1";;
    *.7z) 7z l "$1";;
    *.pdf) pdftotext "$1" -;;
    *.jpg) viu -t "$1" -;;
    *.png) viu -t "$1" -;;
    *.gif) viu -t "$1" -;;
    *) bat --force-colorization --style=numbers --theme gruvbox-dark "$1";;
esac
'';
  };
}
