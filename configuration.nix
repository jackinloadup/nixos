# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, ... }:

let
  settings = import ./settings;
in {
  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      #<nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      # "$(modulesPath)/installer/scan/not-detected.nix"
      ./common/autologin-tty1 # Enable auto login on tty1
    ];

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

  nix.trustedUsers = [ "root"  settings.user.username ];
  nix.package = pkgs.nixUnstable;
  # 1) Enable extra-builtins-file option for nix
  # 2) stuff to get flakes working
  #plugin-files = ${pkgs.nix-plugins.override { nix = config.nix.package; }}/lib/nix/plugins/libnix-extra-builtins.so
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  boot = {
    # Quiet durring boot
    initrd.verbose = false;
    consoleLogLevel = 0;
    kernelParams = [ "quiet" "udev.log_priority=3" ]; 

    tmpOnTmpfs = true; # don't keep /tmp on disk
    cleanTmpDir = true;

    #plymouth.enable = true;

    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot = {
        enable = true;
        memtest86.enable = true; # show memtest
        configurationLimit = 5;
        consoleMode = "auto";
      };
      efi.efiSysMountPoint = "/boot/EFI";
    };
  };

  networking = {
    networkmanager.enable = true;
    dhcpcd.wait = "if-carrier-up";
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = settings.timezone;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # networking.interfaces.enp0s3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Nerdfonts is kinda heavy. We are cutting it fown but still looks like it might be 4-10mb
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  console = {
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
    #config.pipewire-pulse = {
    #  "context.modules" = [
    #    {
    #      name = "libpipewire-module-rtkit";
    #      args = {
    #        "nice.level" = -15;
    #        "rt.prio" = 88;
    #        "rt.time.soft" = 200000;
    #        "rt.time.hard" = 200000;
    #      };
    #      flags = [ "ifexists" "nofail" ];
    #    }
    #  ];
    #};

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
    media-session.config.alsa-monitor.rules = [
      {
        matches = [{ "device.vendor.id" = "4130"; }];
        actions = {
          "update-props" = {
            "device.description" = "AMD Motherboard";
            "device.product.name" = "AMD Motherboard";
          };
        };
      }
      {
        matches = [{ "device.vendor.id" = "4098"; }];
        actions = {
          "update-props" = {
            "device.description" = "AMD GPU";
            "device.product.name" = "AMD GPU";
          };
        };
      }
    ];
  };

  hardware.enableRedistributableFirmware = true;

  # Enable backlight control
  programs.light.enable = true;

  # Enable if minimal setup. Dont use for Gnome/KDE/Xfce
  #sound.mediaKeys.enable = true; # uses alsa amixer by default
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -A 10"; }
      { keys = [ 113 ]; events = [ "key" ]; command = "${pkgs.su}/bin/su lriutzel -c '${pkgs.pulseaudio}/bin/pactl -s /run/user/1000/pulse/native set-sink-mute @DEFAULT_SINK@ toggle'"; }
      { keys = [ 114 ]; events = [ "key" ]; command = "${pkgs.su}/bin/su lriutzel -c '${pkgs.pulseaudio}/bin/pactl -s /run/user/1000/pulse/native set-sink-volume @DEFAULT_SINK@ -5%'"; }
      { keys = [ 115 ]; events = [ "key" ]; command = "${pkgs.su}/bin/su lriutzel -c '${pkgs.pulseaudio}/bin/pactl -s /run/user/1000/pulse/native set-sink-volume @DEFAULT_SINK@ +5%'"; }
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users = {
      ${settings.user.username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "audio"
          "video"
          "networkmanager"
          "corectrl"
        ];
      };
    };
  };

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
  ];

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -ga terminal-overrides ',*256col*:Tc'
    '';
  };

  environment.sessionVariables = {
    EDITOR = "vim";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable CoreCtrl
  programs.corectrl.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  # set logitec mouse to autosuspend after 60 seconds
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="60000"
    '';
}

