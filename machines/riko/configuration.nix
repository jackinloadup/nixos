# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, inputs, pkgs, ... }:

with inputs;
let
  settings = import ../../settings;
in {

  imports = [
    ./hardware-configuration.nix
    ../../common/autologin-tty1 # Enable auto login on tty1
    #<nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    # "$(modulesPath)/installer/scan/not-detected.nix"
    base16.hmModule
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

  networking.hostName = "riko";

  boot = {
    # filefrag -v /var/swapfile to get offset
    #kernelParams = ["resume=/var/swapfile" "resume_offset=17887232" ]; 

    #plymouth.enable = true;

    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot = {
        enable = true;
        memtest86.enable = true; # show memtest
        configurationLimit = 5;
        consoleMode = "auto";
      };
      #systemd-boot.enable = false;
      #grub = {
      #  enable = true;
      #  efiSupport = true;
      #  device = "nodev";
      #  efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      #  forcei686 = true;
      #};

    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ brlaser cups-filters ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable Sane to scan documents.
  hardware.sane.enable = true;
  hardware.sane.brscan4.enable = true;
  hardware.sane.brscan4.netDevices = {
    "Home" = {
      "ip" = "10.16.1.64";
      "model" = "MFC-9130CW";
    };
  };

  # Enable network discovery
  #services.avahi.enable = true;
  #services.avahi.nssmdns = true;

  services.logind.lidSwitch = "suspend-then-hibernate";
  #services.logind.lidSwitch = "hibernate";

  #services.upower.enable = true;
  #services.upower.criticalPowerAction = "Hibernate";

  # set logitec mouse to autosuspend after 60 seconds
  services.udev.extraRules = ''
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="60000"

ACTION!="add|change", GOTO="yubico_end"

# Udev rules for letting the console user access the Yubikey USB
# device node, needed for challenge/response to work correctly.

# Yubico Yubikey II
ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", \
    ENV{ID_SECURITY_TOKEN}="1"

LABEL="yubico_end"
  '';

  services.pcscd.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  #networking.firewall.allowedUDPPorts = [ 5353 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
