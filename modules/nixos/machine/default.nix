{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkDefault mkIf;
  inherit (lib.types) listOf enum nullOr str ints;
  cfg = config.machine;
  settings = import ../../../settings;
  ifTui = config.machine.sizeTarget > 0;
  ifGraphical = config.machine.sizeTarget > 1;
in {
  imports = [
    #flake.inputs.home-manager.nixosModules.home-manager
    #{
    #  home-manager.extraSpecialArgs = {inherit inputs;};
    #  home-manager.useUserPackages = true;
    #  home-manager.backupFileExtension = "hm-backup";
    #}
    ./adb.nix
    ./chromium.nix
    ./encryptedRoot.nix
    ./fonts.nix
    ./quietBoot.nix
    ./gdm.nix
    ./gnome.nix
    ./greetd.nix
    ./impermanence.nix
    ./kernel.nix
    ./lowLevelXF86keys.nix
    ./locale.nix
    ./ly.nix
    ./sddm.nix
    ./sound.nix
    ./ssh.nix
    ./time.nix
    ./tui.nix
    ./minimal.nix
    ./nix.nix
    ./virtualization.nix
    ./magic-key.nix
    ./wayland.nix
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
    users = mkOption {
      type = listOf (enum []);
      default = [];
      example = ["john" "jane" "liljohn"];
      description = "What users will be loaded onto the machine";
    };
  };

  config = {
    # Let 'nixos-version --json' know the Git revision of this flake.
    system.configurationRevision = mkIf (flake.inputs.self ? rev) flake.inputs.self.rev;

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
      initrd = {
        # It's possible for systemd to add or remove store paths and bins
        systemd.enable = true;
        # TODO pull into profile or something
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
      tmp.useTmpfs = true;
      tmp.cleanOnBoot = true;

      loader.systemd-boot = {
        enable = mkDefault true;
        memtest86.enable = mkDefault true; # show memtest
        configurationLimit = mkDefault 5;
        consoleMode = mkDefault "auto";
        netbootxyz.enable = true;
      };

      # Imporved networking
      kernelModules = ["tcp_bbr"];
      kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
      kernel.sysctl."net.core.default_qdisc" = "fq";
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget

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
          # random not good for servers
          macAddress = mkDefault "random";
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

      graphics.enable = mkDefault ifGraphical;
      # antiquated in 24.11
      #opengl.driSupport = mkDefault ifGraphical;
      #opengl.driSupport32Bit = mkDefault ifGraphical;

# look into this more
# saw this on "Exploring AMD Error Correction RAS Engineering - Level1Techs"
      rasdaemon.enable = false;
    };

    home-manager.backupFileExtension = "backup";

    programs.dconf.enable = mkDefault ifGraphical;

    security.pam.loginLimits = [
      { domain = "*"; type = "soft"; item = "nofile"; value = "65536"; }
      { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
    ];

    security.pam.sshAgentAuth.enable = mkDefault true; # todo explore to see if it fixes the nixos-rebuld need for the ssh flag
    #security.pam.services.sudo.unixAuth = false;
    security.pam.services.sudo.sshAgentAuth = true;

    #security.pam.services.polkit-1.unixAuth = false;
    security.pam.services.polkit-1.sshAgentAuth = true;
    security.pam.services.login.sshAgentAuth = true;

    # users who are smart can be trusted?
    security.sudo.wheelNeedsPassword = false;

    # https://kokada.dev/blog/an-unordered-list-of-hidden-gems-inside-nixos/
    # use high performance implementation
    services.dbus.implementation = "broker";

    # Fuse filesystem that returns symlinks to executables based on the PATH of
    # the requesting process. This is useful to execute shebangs on NixOS that
    # assume hard coded locations in locations like /bin or /usr/bin etc.
    #
    # I don't have a direct need, but this should help when encountering an
    # application not prepared for NixOS
    services.envfs.enable = ifGraphical;

    ## Enable updating firmware via the command line.
    services.fwupd.enable = mkDefault ifTui;

    services.gvfs.enable = mkDefault ifGraphical;
    # For user-space mounting things like smb:// and ssh:// in thunar etc. Dbus
    # is required.
    #services.gvfs.package = lib.mkForce pkgs.gnome3.gvfs;
    services.gvfs.package = mkDefault pkgs.gvfs;

    services.xserver.desktopManager.xterm.enable = mkDefault false;

    services.ddccontrol.enable = true;

    services.journald.extraConfig = ''
      SystemMaxUse=100M
      MaxFileSec=7day
    '';

    # Enable network discovery
    services.avahi = {
      enable = mkDefault ifGraphical;
    # resolve .local names
      nssmdns4 = true;
      openFirewall = true;
      publish.enable = true;
      ipv4 = true;
      ipv6 = false;
    };

    services.printing.enable = mkDefault ifGraphical;
    programs.system-config-printer.enable = mkDefault ifGraphical;
    services.system-config-printer.enable = mkDefault ifGraphical;

    # A way to somewhat mimic normal linux systems. Could help random
    # bashscripts work
    # When implimented I didn't actually need this. I saw it on youtube and
    # thought it might be useful    services.avahi.enable
    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin"
    ];

    # show IP in login screen
    # https://github.com/NixOS/nixpkgs/issues/63322
    environment.etc."issue.d/ip.issue".text = "\\4\n";
    networking.dhcpcd.runHook = "${pkgs.util-linux}/bin/agetty --reload";

    # explore multi level compression
    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };
  };
}
