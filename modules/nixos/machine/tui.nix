{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption types;
  cfg = config.machine;
  settings = import ../../../settings;
in {
  imports = [
    ./base16.nix
    ./tmux.nix
  ];

  options.machine.tui = mkEnableOption "Extensive tui tools";

  config = mkIf cfg.tui {
    environment.systemPackages =
      (with pkgs; [
        pv # progress meter

        #vim # text editor
        #neovim # text editor
        fswatch # file change monitor

        git # source code manager

        #ncpamixer # couldn't get it to work

        #vlock # tty/vtty locker
        # fasd # quick access to files and dir

        eza # ls replacement
        jq # json parsing
        tree # file/directory viewer in tree format
        ripgrep # grep alternative
        rsync
        # pass # password manager # not in use atm
        lf # file manager
        #  highlight # highlight files for previews
        #  poppler_utils # for pdf2text
        bat # cat alternative
        viu # terminal image viewer
        lesspipe
        #reptyr # Reparent a running program to a new terminal # stopped building 2/25/24

        ## compression tools
        unzip
        #unrar #unfree
        unrar-wrapper # free wrapper around unrar
        p7zip

        ## http/web
        lynx # text web browser
        wget # http client
        curl # http client

        # Debug
        ## hardware
        pciutils
        powertop # debug power usage and battery draw
        lshw # list hardware
        dmidecode # Read DMI (SMBIOS)
        # builds cuda stuffs
        #nvtop # A (h)top like task monitor for AMD, Intel and NVIDIA GPUs
        libinput # input device debugging tool
        evtest # input device debugging tool

        # Disk
        parted # a partition manipulation program

        ## network
        iftop # a partition manipulation program
        #latencytop # has been removed due to lack of maintenance upstream
        jnettop # View hosts/ports taking up the most network traffic
        dnstop # displays various tables of DNS traffic on your network
        dnsutils # provide dig nslookup nsupdate
        mtr # traceroute and ping
        bridge-utils # brctl

        ## io
        iotop # simple top-like I/O monitor
        #input-utils # lsinput - error: The input-utils package was dropped since it was unmaintained
        nmon # performance stats monitor
        i2c-tools # some tools also exist in toy/busybox

        ## files
        lsof # list open files
        ncdu # ncurses disk usage viewer
        dust # disk usage viewer kinda, not sold over ncdu
        file # determine file type
        fd # find alternative
        btrfs-progs

        ## Executables
        binutils
        patchelf

        ## OS (nix/linux)
        nix-tree # A terminal curses application to browse a Nix store paths dependencies
        nix-diff
        vulnix # vulnerability scanner for nix
        # atop?
      ])
      ++ (with config.boot.kernelPackages; [
        turbostat # Report processor frequency and idle statistics
        perf # Linux tools to profile with performance counters
        tmon # Monitoring and Testing Tool for Linux kernel thermal subsystem
        usbip # allows to pass USB device from server to client over the network
      ]);

    console = {
      earlySetup = mkDefault true;
      keyMap = "us";
      # might be set in machine/fonts.nix
      #font = "ter-132n";
      #packages = with pkgs; [ terminus_font ];
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

    # haven't tested placing for reference
    #services.kmscon = {
    #  enable = true;
    #  hwRender = true;
    #  extraConfig =
    #  ''
    #    font-name=MesloLGS NF
    #    font-size=14
    #  '';
    #};

    #programs.autojump.enable = true;
    programs = {
      bash = {
        interactiveShellInit = ''
          source ${config.lib.base16.templateFile {name = "shell";}}
        '';
      };

      htop = {
        enable = true;
        settings = {
          hide_kernel_threads = true;
          hide_userland_threads = true;
        };
      };

      less = {
        enable = true;
        #configFile = {
        #};
        envVariables = {
          LESS = "-R --quit-if-one-screen";

          LESSHISTFILE = "$XDG_CACHE_HOME/less.hst";
          LESSHISTSIZE = "1000";
        };
      };
    };

    # interups `nix store ping` and some ssh sessions when in
    #   environment.sessionVariables
    # might need to be interactive only.
    # less.envVariables is worse than environment.sessionVariables
    # the commands aren't evaluated. They are printed in place.
    programs.zsh.interactiveShellInit = ''
         export LESS_TERMCAP_mb="$(tput bold; tput setaf 2)";
         export LESS_TERMCAP_md="$(tput bold; tput setaf 3)";
         export LESS_TERMCAP_me="$(tput sgr0)";
         export LESS_TERMCAP_so="$(tput bold; tput setaf 3; tput setab 4)";
         export LESS_TERMCAP_se="$(tput rmso; tput sgr0)";
         export LESS_TERMCAP_us="$(tput smul; tput bold; tput setaf 2)";
         export LESS_TERMCAP_ue="$(tput rmul; tput sgr0)";
         export LESS_TERMCAP_mr="$(tput rev)";
         export LESS_TERMCAP_mh="$(tput dim)";
         export LESS_TERMCAP_ZN="$(tput ssubm)";
         export LESS_TERMCAP_ZV="$(tput rsubm)";
         export LESS_TERMCAP_ZO="$(tput ssupm)";
         export LESS_TERMCAP_ZW="$(tput rsupm)";
    '';

    environment.sessionVariables = {
      EDITOR = "vim";
    };

    environment.shellAliases = {
      ".." = "cd ..";
      "ncdu" = "ncdu --color dark";
      "nixos-current-repl" = "nix repl --file '<repl>'";
    };

    environment.etc = {
      "lf/lfrc".text = ''
        set previewer /etc/lf/pv.sh
        map i $LESSOPEN='| /etc/lf/pv.sh %s' less -R $f
        cmd open ''${{
            case $(file --mime-type $f -b) in
                text/*) $EDITOR $fx;;
                image/*) imv $fx;;
                *) for f in $fx; do xdg-open $f > /dev/null 2> /dev/null & done;;
            esac
        }}
      '';
      "lf/pv.sh" = {
        mode = "0755";
        text = ''
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
              *.iso) fdisk -l "$1" -;;
              *) bat --force-colorization --style=numbers --theme gruvbox-dark "$1";;
          esac
        '';
      };
    };
  };
}
