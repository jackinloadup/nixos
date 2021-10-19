{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    ./encryptedRoot.nix
    ./quietBoot.nix
  ];


  options.machine = {
    encryptedRoot = mkEnableOption "Enable luks handling for /root is encyption";
    useSystemdBoot = mkEnableOption "Use systemd-boot instead of grub";
    hasBattery = mkEnableOption "Does this machines have a battery?";
    quietBoot = mkEnableOption "Hide boot log";
  };

  config = {
    themes.base16 = {
      enable = true;
      #scheme = "solarized";
      #variant = "solarized-dark";
      scheme = "gruvbox";
      variant = "gruvbox-dark-hard";
      #variant = "gruvbox-dark-medium";
      defaultTemplateType = "default";
      # Add extra variables for inclusion in custom templates
      extraParams = {
        fontName = "FiraCode Nerd Font";
        fontSize = "12";
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

    programs.dconf.enable = true; # needed for HM.gtk.enable true

    users = {
      users = {
        ${settings.user.username} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "audio"
            "video"
            "networkmanager"
            "scanner" "lp"
            "i2c"
          ];
        };
      };
    };

    boot = {
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
      loader.systemd-boot.consoleMode = mkDefault "auto";
    };

    xdg = {
      portal = {
        enable = true;
        gtkUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
      };
    };

    # Nerdfonts is kinda heavy. We are cutting it fown but still looks like it might be 4-10mb
    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      lato
    ];

    #TODO light doesn't work for all systems or is needed for all systems
    # Enable backlight control
    programs.light.enable = true;

    # Enable if minimal setup. Dont use for Gnome/KDE/Xfce
    #sound.mediaKeys.enable = true; # uses alsa amixer by default
    services.actkbd =
      let
        user_run = "/run/user/${toString settings.user.uid}";
        dbus = "DBUS_SESSION_BUS_ADDRESS=unix:path=${user_run}/bus";
        dunstify = "${dbus} ${pkgs.dunst}/bin/dunstify --replace=${toString settings.user.uid} --timeout=2000";
        bash = "${pkgs.su}/bin/su ${settings.user.username} -s ${pkgs.bash}/bin/bash";
        playerctl = "${dbus} ${pkgs.playerctl}/bin/playerctl";
        pactl = "${pkgs.pulseaudio}/bin/pactl -s ${user_run}/pulse/native";

        # get mute as 0=yes,mutted 1=no,umutted
        is_mute = "${pactl} list sinks | ${pkgs.ripgrep}/bin/rg -A 7 RUNNING | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.coreutils}/bin/head -1  | ${pkgs.coreutils}/bin/cut -d \"/\" -f2 | ${pkgs.coreutils}/bin/tr -d \" \" | ${pkgs.gnugrep}/bin/grep -q yes";
        # get audio volume as percent int eg 80
        current_volume  = "${pactl} list sinks | ${pkgs.ripgrep}/bin/rg -A 8 RUNNING | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.coreutils}/bin/head -1  | ${pkgs.coreutils}/bin/cut -d \"/\" -f2 | ${pkgs.coreutils}/bin/tr -d \" %\"";
        set_volume_mute = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
        set_volume_up   = "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
        set_volume_down = "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
        notify_current_volume = "${dunstify} \"Volume\" -h int:value:`${current_volume}`";
        notify_muted          = "${dunstify} \"Volume Muted\" -t 0 -h int:value:0";
      in {
        enable = true;
        bindings = [
          { keys = [ 224 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -U 10"; }
          { keys = [ 225 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -A 10"; }
          { keys = [ 113 ]; events = [ "key" ]; command = "${bash} -c '${set_volume_mute} && ${is_mute} && ${notify_muted} || ${notify_current_volume}'"; }
          { keys = [ 114 ]; events = [ "key" ]; command = "${bash} -c '${set_volume_down} && ${notify_current_volume}'"; }
          { keys = [ 115 ]; events = [ "key" ]; command = "${bash} -c '${set_volume_up}   && ${notify_current_volume}'"; }
          { keys = [ 163 ]; events = [ "key" ]; command = "${bash} -c '${playerctl} next       '"; }
          { keys = [ 164 ]; events = [ "key" ]; command = "${bash} -c '${playerctl} play-pause && ${dunstify} \"Play-Pause: \"'"; }
          { keys = [ 165 ]; events = [ "key" ]; command = "${bash} -c '${playerctl} previous   '"; }
      ];
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


    programs.zsh.enable = true;
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim # text editor
      wget # http client
      curl # http client
      git # source code manager
      tmux # terminal multiplexer
      htop # process, cpu, memory viewer
      lynx # text web browser
      ncdu # ncurses disk usage viewer
      mtr # traceroute and ping
      pulseaudio # for pactl and other things like it just not enabled
      #ncpamixer # couldn't get it to work
      vlock # tty/vtty locker
      jq # json parsing
      tree # file/directory viewer in tree format
      ripgrep # grep alternative
      rsync
      #flavours
      nix-tree # A terminal curses application to browse a Nix store paths dependencies
      pass # password manager
      nix-plugins # Collection of miscellaneous plugins for the nix expression language
      yubikey-manager
      yubikey-personalization
      lsof
      neovim

      # Debug
      pciutils
      powertop
      iftop
      latencytop
      jnettop
      iotop
      dnstop
      input-utils # lsinput
      # atop?

    ];

    powerManagement = {
      enable = true;
      powertop.enable = true;
    };

    networking = {
      # Enable wifi powersaving.
      networkmanager = {
        enable = lib.mkDefault true;
        wifi = {
          #enable = true;  # Enables wireless support via wpa_supplicant.
          powersave = true;
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
    services.openssh.enable = true; #TODO limit to authorized keys only

    hardware = {
      # Enable firmware for bluetooth/wireless (Intel® Wireless-AC 9560).
      enableRedistributableFirmware = mkDefault true;

      opengl = {
        enable = true;
        driSupport = true;
      };
    };

    # Set your time zone.
    time.timeZone = settings.timezone;

    # networking.interfaces.enp0s3.useDHCP = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    # Enable sound.
    sound.enable = false; # conflicts with pipewire?

    security = {
      pam.services.swaylock = {}; # tmp hack to allow swaylock to work
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

      # High quality BT calls
      media-session.config.bluez-monitor.rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            };
          };
        }
        {
          matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
          actions = {
            "node.pause-on-idle" = false;
          };
        }
      ];
    };

    ## Enable periodic trim for long term SSD performance.
    #services.fstrim.enable = true;

    ## Enable updating firmware via the command line.
    #services.fwupd.enable = true;

    ## Enable cpu specific power saving features.
    #services.thermald.enable = true;

    ## Enable fix for lenovo cpu throttling issue.
    #services.throttled.enable = true;

    #nix.maxJobs = lib.mkDefault 8;

    environment.sessionVariables = {
      EDITOR = "vim";
    };

    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      extraConfig = ''
        set -ga terminal-overrides ',*256col*:Tc'
        source ${config.lib.base16.templateFile { name="tmux"; }}
      '';
    };

    # add config above here
  };
}
