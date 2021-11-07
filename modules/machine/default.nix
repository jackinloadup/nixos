{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    ./encryptedRoot.nix
    ./quietBoot.nix
    ./lowLevelXF86keys.nix
    ./sway.nix
  ];


  options.machine = {
    #useSystemdBoot = mkEnableOption "Use systemd-boot instead of grub";
    #hasBattery = mkEnableOption "Does this machines have a battery?";
    sizeTarget = mkOption {
      type = types.int;
      default = 2;
      example = 0;
      description = "Hint for module to allow for smaller built outputs. 0=Minimal 1=Lite 2=Normal";
    };
    debugTools = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "hardware" "network" "os" "fs" "tui" "gui" "all" ];
      description = "The category of debug tools to be install";
    };
    includeDocs = mkEnableOption "Should documentation be installed?";
  };

  config = {
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

    nixpkgs.config.allowUnfree = true;

    nix.package = pkgs.nixUnstable; # support flakes
    nix.trustedUsers = [ "root"  settings.user.username ];
    nix.autoOptimiseStore = true;
    # 1) Enable extra-builtins-file option for nix
    # 2) stuff to get flakes working
    #plugin-files = ${pkgs.nix-plugins.override { nix = config.nix.package; }}/lib/nix/plugins/libnix-extra-builtins.so
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    users = {
      users = with settings.user; {

        ${username} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "audio"
            "video"
            "networkmanager"
            "wireshark"
          ];
        };
      };
    };

    boot = {
      #plymouth.enable = true;
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "nvme"
          "usb_storage"
          "uas"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
      };

      # don't keep /tmp on disk
      tmpOnTmpfs = true;
      cleanTmpDir = true;

      loader.systemd-boot = {
        enable = mkDefault true;
        #memtest86.enable = true; # show memtest
        configurationLimit = mkDefault 5;
        consoleMode = mkDefault "auto";
      };
    };

    xdg = {
      portal = {
        enable = true;
        gtkUsePortal = true;
      };
    };

    # Nerdfonts is kinda heavy. We are cutting it fown but still looks like it might be 4-10mb
    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      lato
    ];

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
        eval "$(starship init bash)"
      '';
      undistractMe = {
        enable = true;
        timeout = 10;
        playSound = true;
      };
    };

    programs.wireshark.enable = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      starship

      pv # progress meter

      #vim # text editor
      neovim # text editor

      git # source code manager

      tmux # terminal multiplexer
      #tmux-cssh

      pulseaudio # for pactl and other things like it just not enabled
      #ncpamixer # couldn't get it to work
      #vlock # tty/vtty locker
      jq # json parsing
      tree # file/directory viewer in tree format
      ripgrep # grep alternative
      rsync
      pass # password manager
      nix-plugins # Collection of miscellaneous plugins for the nix expression language
      lf # file manager
      highlight # highlight files for previews
      poppler_utils
      bat # cat alternative
      viu # terminal image viewer
      emulsion # mimimal linux image viewer built in rust

      ## compression tools
      unzip
      unrar
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
      nmap-graphical
      mtr # traceroute and ping

      ## io
      iotop
      input-utils # lsinput

      ## files
      lsof
      ncdu # ncurses disk usage viewer
      file

      ## OS (nix/linux)
      nix-tree # A terminal curses application to browse a Nix store paths dependencies
      # atop?
      htop # process, cpu, memory viewer

    ];

    powerManagement = {
      enable = true;
      cpuFreqGovernor = lib.mkDefault "ondemand";
      powertop.enable = true; # if debug?
    };

    networking = {
      networkmanager = {
        enable = lib.mkDefault true;
        wifi = {
          #enable = true;  # Enables wireless support via wpa_supplicant.
          powersave = true; # Enable wifi powersaving. Not exactly sure if this is working
          macAddress = "random";
        };
      };
      dhcpcd.wait = "background";

      # The global useDHCP flag is deprecated, therefore explicitly set to false here.
      # Per-interface useDHCP will be mandatory in the future, so this generated config
      # replicates the default behaviour.
      useDHCP = false;

      firewall.enable = true;
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

    hardware = {
      # Enable firmware for bluetooth/wireless (Intel® Wireless-AC 9560).
      enableRedistributableFirmware = mkDefault true;

      opengl = {
        driSupport = true;
      };
    };

    # Set your time zone.
    time.timeZone = settings.home.timezone;

    # Select and limit locales
    i18n = with settings.user;
    let
      localeFull = "${locale}.${characterSet}";
      localeExtended = "${localeFull}/${characterSet}";
    in {
      supportedLocales = [ localeExtended ];
      defaultLocale = localeFull;
      glibcLocales = pkgs.glibcLocales.override {
        allLocales = false;
        locales = [ localeExtended ];
      };
    };

    # Enable sound.
    sound.enable = false; # conflicts with pipewire?

    security = {
      rtkit.enable = true; # allows pipewire to run "realtime"
    };

    # Disable pulseaudio
    hardware.pulseaudio.enable = false;
    # Enable pipewire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    ## Enable updating firmware via the command line.
    services.fwupd.enable = true;

    environment.sessionVariables = {
      EDITOR = "vim";
    };

    environment.shellAliases = {
      "ncdu" = "ncdu --color dark";
    };

    programs.less.configFile = {
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
    #*) highlight -O truecolor "$1";;


    # Enable network discovery
    #services.avahi.enable = true;
    #services.avahi.nssmdns = true;

    # Set on each machine that builds
    #nix.maxJobs = lib.mkDefault 8;

    # add config above here
  };
}
