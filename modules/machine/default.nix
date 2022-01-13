{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    ./chirp.nix
    ./encryptedRoot.nix
    ./fonts.nix
    ./quietBoot.nix
    ./lowLevelXF86keys.nix
    ./adb.nix
    ./docker.nix
    ./sway.nix
    ./sound.nix
    ./tui.nix
    ./minimal.nix
    ./nix.nix
    ./virtualization.nix
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
  };

  config = {
    # Allow unfree packages.
    nixpkgs.config.allowUnfree = if (cfg.sizeTarget > 0)  then true else false;

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

      kernelParams = [
        # If boot fails panic
        "boot.panic_on_fail"

        # reboot x seconds after panic. allow time for vmcore memory image to be saved
        # time require is related to memory size and storage speed.
        # 30 secs was recommended
        "panic=10" # reboot 10 second after panic

        # panic immediately if oom killer is activated
        #"vm.panic_on_oom"

        # how long a user or kernel thread can remain in D state before kernel panic
        #"hung_task_timeout_secs=120"

        # Panic if hung task is found
        #"kernel.hung_task_panic=1"
      ];
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
        enable = mkIf (cfg.sizeTarget > 0) true;
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

    # Set your time zone.
    time.timeZone = mkDefault settings.home.timezone;

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

    ## Enable updating firmware via the command line.
    services.fwupd.enable = mkIf (cfg.sizeTarget > 0) true;

    programs.dconf.enable = mkIf (cfg.sizeTarget > 0) true;

    services.gvfs.enable = mkIf (cfg.sizeTarget > 1) true;
    # For user-space mounting things like smb:// and ssh:// in thunar etc. Dbus
    # is required.
    services.gvfs.package = lib.mkForce pkgs.gnome3.gvfs;

    #*) highlight -O truecolor "$1";;


    # Enable network discovery
    #services.avahi.enable = true;
    #services.avahi.nssmdns = true;

    # Set on each machine that builds
    #nix.maxJobs = lib.mkDefault 8;

    # add config above here
  };
#} else {});
}
