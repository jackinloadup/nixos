{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.machine;
in {
  imports = [
    ./tmux.nix
  ];

  options.machine.tui = mkEnableOption "Extensive tui tools";

  config = mkIf cfg.tui {
    environment.systemPackages =
      (with pkgs; [
        # don't know what I needed these for
        #pkgs.fuse3
        #pkgs.libva-utils

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
        #unrar-wrapper # free wrapper around unrar
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
