{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    ./adb.nix
    ./chirp.nix
    ./encryptedRoot.nix
    ./fonts.nix
    ./quietBoot.nix
    ./gdm.nix
    ./gnome.nix
    ./greetd.nix
    ./i3.nix
    ./kernel.nix
    ./lowLevelXF86keys.nix
    ./locale.nix
    ./ly.nix
    ./docker.nix
    ./sway.nix
    ./sound.nix
    ./tui.nix
    ./minimal.nix
    ./nix.nix
    ./virtualization.nix
    ./magic-key.nix
  ];


  options.machine = {
    #useSystemdBoot = mkEnableOption "Use systemd-boot instead of grub";
    #hasBattery = mkEnableOption "Does this machines have a battery?";
    sizeTarget = mkOption {
      type = types.ints.between 0 2;
      default = 2;
      example = 0;
      description = "Hint for module to allow for smaller built outputs. 0=Minimal 1=Lite 2=Normal";
    };
    debugTools = mkOption {
      type = with types; listOf enum [ "hardware" "network" "os" "fs" "tui" "gui" ];
      default = [];
      example = [ "hardware" "network" "os" "fs" "tui" "gui"];
      description = "The category of debug tools to be install";
    };
    includeDocs = mkEnableOption "Should documentation be installed?";
    users = mkOption {
      type = with types; listOf (enum [ ]);
      default = [ ];
      example = [ "john" "jane" "liljohn" ];
      description = "What users will be loaded onto the machine";
    };
    defaultUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "whodis"; # ?
      description = "Declare if there is a user who should be considered the default user. Enables things like autologin";
    };
    mutableUsers = mkEnableOption "Should kernel panic when the out-of-memory daemon is triggerd";
    displayManager = mkOption {
      type = with types; nullOr (enum [ ]);
      default = null;
      example = [ "gdm" "lightdm" "ly" ];
      description = "Application which manages the physical user seat";
    };
    windowManagers = mkOption {
      type = with types; nullOr (listOf (enum [ ]));
      default = null;
      example = "gnome";
      description = "Available window manager environments. ex: Gnome KDE XFCE";
    };
  };

  config = {
    # Allow unfree packages.
    nixpkgs.config.allowUnfree = if (cfg.sizeTarget > 0)  then true else false;

    users.mutableUsers = mkDefault cfg.mutableUsers; # Users may only be added via nix config

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
        availableKernelModules = mkIf (cfg.sizeTarget > 0) [
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

      # Imporved networking TESTING ATM
      kernelModules = [ "tcp_bbr" ];
      kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
      kernel.sysctl."net.core.default_qdisc" = "fq";
    };
#  } // (if cfg.sizeTarget > -1 then {

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 0) [
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language
      emulsion # mimimal linux image viewer built in rust
      nmap-graphical

      fuse3
    ];

    powerManagement = {
      enable = mkIf (cfg.sizeTarget > 0) true;
      cpuFreqGovernor = mkDefault "ondemand";
      powertop.enable = mkIf (cfg.sizeTarget > 0) true; # if debug?
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
      dhcpcd.wait = "background";

      # The global useDHCP flag is deprecated, therefore explicitly set to false here.
      # Per-interface useDHCP will be mandatory in the future, so this generated config
      # replicates the default behaviour.
      useDHCP = false;

      firewall.enable = true;
    };


    hardware = {
      # Enable firmware for bluetooth/wireless (Intel® Wireless-AC 9560).
      enableRedistributableFirmware = mkIf (cfg.sizeTarget > 0) true;

      opengl.driSupport = mkIf (cfg.sizeTarget > 0) true;
    };


    ## Enable updating firmware via the command line.
    services.fwupd.enable = mkIf (cfg.sizeTarget > 0) true;

    programs.dconf.enable = mkIf (cfg.sizeTarget > 0) true;

    services.gvfs.enable = mkIf (cfg.sizeTarget > 1) true;
    # For user-space mounting things like smb:// and ssh:// in thunar etc. Dbus
    # is required.
    services.gvfs.package = lib.mkForce pkgs.gnome3.gvfs;

    services.xserver.desktopManager.xterm.enable = false;


    # Enable network discovery
    #services.avahi.enable = true;
    #services.avahi.nssmdns = true;

    # show IP in login screen
    # https://github.com/NixOS/nixpkgs/issues/63322
    environment.etc."issue.d/ip.issue".text = "\\4\n";
    networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";

    # add config above here
  };
#} else {});
}
