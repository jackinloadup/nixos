{ lib, pkgs, config, inputs, ... }:
let
  inherit (lib) mkOption mkEnableOption mkDefault mkIf;
  inherit (lib.types) listOf enum nullOr str ints;
  cfg = config.machine;
  settings = import ../../settings;
  ifTui = config.machine.sizeTarget > 0;
  ifGraphical = config.machine.sizeTarget > 1;
in {
  imports = [
    "${inputs.impermanence}/nixos.nix"
    inputs.home-manager.nixosModules.home-manager {
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
    }
    ./adb.nix
    ./chirp.nix
    ./chromium.nix
    ./encryptedRoot.nix
    ./fonts.nix
    ./quietBoot.nix
    ./gdm.nix
    ./gnome.nix
    ./greetd.nix
    ./i3.nix
    ./impermanence.nix
    ./kernel.nix
    ./lowLevelXF86keys.nix
    ./locale.nix
    ./ly.nix
    ./docker.nix
    ./sway.nix
    ./sound.nix
    ./ssh.nix
    ./tui.nix
    ./minimal.nix
    ./nix.nix
    ./virtualization.nix
    ./magic-key.nix
  ];

  ## TODO disable user mutab

  options.machine = {
    #useSystemdBoot = mkEnableOption "Use systemd-boot instead of grub";
    #hasBattery = mkEnableOption "Does this machines have a battery?";
    sizeTarget = mkOption {
      type = ints.between 0 3;
      default = 2;
      example = 0;
      description = "Hint for module to allow for smaller built outputs. 0=Minimal 1=Tui 2=Graphical 3=Full";
    };
    debugTools = mkOption {
      type = listOf enum [ "hardware" "network" "os" "fs" "tui" "gui" ];
      default = [];
      example = [ "hardware" "network" "os" "fs" "tui" "gui"];
      description = "The category of debug tools to be install";
    };
    includeDocs = mkEnableOption "Should documentation be installed?";
    users = mkOption {
      type =  listOf (enum [ ]);
      default = [ ];
      example = [ "john" "jane" "liljohn" ];
      description = "What users will be loaded onto the machine";
    };
    defaultUser = mkOption {
      type = nullOr str;
      default = null;
      example = "whodis"; # ?
      description = "Declare if there is a user who should be considered the default user. Enables things like autologin";
    };
    displayManager = mkOption {
      type = nullOr (enum [ ]);
      default = null;
      example = [ "gdm" "lightdm" "ly" ];
      description = "Application which manages the physical user seat";
    };
    windowManagers = mkOption {
      type = nullOr (listOf (enum [ ]));
      default = null;
      example = "gnome";
      description = "Available window manager environments. ex: Gnome KDE XFCE";
    };
  };

  config = {
    # Allow unfree packages.
    nixpkgs.config.allowUnfree = true;

    # Let 'nixos-version --json' know the Git revision of this flake.
    system.configurationRevision = mkIf (inputs.self ? rev) inputs.self.rev;

    users.mutableUsers = mkDefault false; # Users may only be added via nix config

    time.timeZone = mkDefault settings.home.timezone;

    machine.kernel = {
      rebootAfterPanic = mkDefault 10;
      panicOnOOM = mkDefault false;
      panicOnFailedBoot = mkDefault true;
      panicOnHungTask = mkDefault true;
      panicOnHungTaskTimeout = mkDefault 120;
    };

    boot = {
      #plymouth.enable = true;
      initrd = {
        availableKernelModules = mkIf ifTui [
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
        memtest86.enable = mkDefault ifTui; # show memtest
        configurationLimit = mkDefault 5;
        consoleMode = mkDefault "auto";
      };

      # Imporved networking TESTING ATM
      kernelModules = [ "tcp_bbr" ];
      kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
      kernel.sysctl."net.core.default_qdisc" = "fq";
    };
#  } // (if cfg.sizeTarget > -1 then {

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; mkIf ifTui [
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language

      fuse3
      libva-utils
    ];

    powerManagement = {
      enable = mkDefault ifTui;
      cpuFreqGovernor = mkDefault "ondemand";
      powertop.enable = mkDefault ifTui; # if debug?
    };

    networking = {
      networkmanager = {
        enable = mkDefault true;
        wifi = {
          #enable = true;  # Enables wireless support via wpa_supplicant.
          powersave = true; # Enable wifi powersaving. Not exactly sure if this is working
          macAddress = "random";
        };
      };
      dhcpcd.wait = mkDefault "background";

      # The global useDHCP flag is deprecated, therefore explicitly set to false here.
      # Per-interface useDHCP will be mandatory in the future, so this generated config
      # replicates the default behaviour.
      useDHCP = false;

      firewall.enable = true;
    };


    hardware = {
      # Enable firmware for bluetooth/wireless (Intel® Wireless-AC 9560).
      enableAllFirmware = mkDefault config.nixpkgs.config.allowUnfree;
      enableRedistributableFirmware = mkDefault config.nixpkgs.config.allowUnfree;

      opengl.enable = mkDefault ifGraphical;
      opengl.driSupport = mkDefault ifGraphical;
    };

    ## Enable updating firmware via the command line.
    services.fwupd.enable = mkDefault ifTui;

    programs.dconf.enable = mkDefault ifGraphical;

    services.gvfs.enable = mkDefault ifGraphical;
    # For user-space mounting things like smb:// and ssh:// in thunar etc. Dbus
    # is required.
    #services.gvfs.package = lib.mkForce pkgs.gnome3.gvfs;
    services.gvfs.package = mkDefault pkgs.gvfs;

    services.xserver.desktopManager.xterm.enable = false;

    services.journald.extraConfig = ''
      SystemMaxUse=100M
      MaxFileSec=7day
    '';

    # Enable network discovery
    #services.avahi.enable = true;
    #services.avahi.nssmdns = true;

    # show IP in login screen
    # https://github.com/NixOS/nixpkgs/issues/63322
    environment.etc."issue.d/ip.issue".text = "\\4\n";
    networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";

    # explore multi level compression
    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };
  };
}
