# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, ... }:
 
let
  settings = import ./settings;
  colorscheme = settings.colorscheme;
in {
  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      #<nixpkgs/nixos/modules/installer/scan/not-detected.nix>
     # "$(modulesPath)/installer/scan/not-detected.nix"
     ./common/autologin-tty1
    ];

  # tmp hack to allow swaylock to work
  security.pam.services.swaylock = {};
  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  boot = {
    # quiet durring boot
    initrd.verbose = false;
    consoleLogLevel = 0;
    kernelParams = [ "quiet" "udev.log_priority=3" ]; 

    # don't keep /tmp on disk
    tmpOnTmpfs = true;
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

  # Enable auto login
  #services.getty.autologinUser = settings.user.username;
  #services."autovt@tty1" = {
  #  after = [ "systemd-logind.service" ];
  #  restartIfChanged = false;
  #  serviceConfig = {
  #    Type = "simple";
  #    ExecStart = "${pkgs.utillinux}/sbin/agetty --autologin ${settings.user.username} --noclear %I $TERM";
  #    Restart = "always";
  #  };
  #};

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
  console.colors = with colorscheme; [
   bg_0		# 0
   red		# 1
   green	# 2
   yellow 	# 3
   blue		# 4
   violet	# 5
   cyan		# 6
   dim_0	# 7
   fg_0		# 8
   br_red	# 9
   br_green	# 10
   br_yellow	# 11
   br_blue	# 12
   br_violet	# 13
   br_cyan	# 14
   fg_1		# 15 
  ];

  # Nerdfonts is kinda heavy. We are cutting it fown but still looks like it might be 4-10mb
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = false; # conflicts with pipewire?

  security.rtkit.enable = true; # allows pipewire to run "realtime"
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
  };
  hardware.pulseaudio.enable = false;
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
        ];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tmux
    htop
    lynx
    ncdu
    mtr
    pulseaudio # for pactl and other things like it just not enabled
    #ncpamixer # couldn't get it to work
    vlock
  ];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_CURRENT_DESKTOP = "sway"; 
    XDG_SESSION_TYPE = "wayland";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}

