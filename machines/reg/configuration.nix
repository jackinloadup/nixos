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
    scheme = settings.theme.base16.scheme;
    variant = settings.theme.base16.variant;
    defaultTemplateType = "default";
    # Add extra variables for inclusion in custom templates
    extraParams = {
      fontName = settings.theme.font.mono.family;
      fontSize = settings.theme.font.size;
    };
  };

  machine = {
    bluetooth = true;
    steam = true;
    starlight = false;
    encryptedRoot = true;
    quietBoot = true;
    simula = true;
    home-assistant = true;
    gaming = true;
  };

  networking.hostName = "reg";

  boot = {
    # filefrag -v /var/swapfile to get offset
    kernelParams = ["resume=/var/swapfile" "resume_offset=17887232" ]; 

    #plymouth.enable = true;

    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot = {
        enable = true;
        memtest86.enable = true; # show memtest
        configurationLimit = 5;
      };
    };
  };

  # Enable pipewire
  services.pipewire = {
    media-session.config.alsa-monitor.rules = [
      {
        matches = [{ "device.vendor.id" = "4130"; }];
        actions = {
          "update-props" = {
            "device.description" =  "Motherboard";
            "device.product.name" = "Motherboard";
          };
        };
      }
      {
        matches = [{ "device.vendor.id" = "4098"; }];
        actions = {
          "update-props" = {
            "device.description" =  "GPU";
            "device.product.name" = "GPU";
          };
        };
      }
    ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  # List services that you want to enable:

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ brlaser cups-filters ];

  # Enable Sane to scan documents.
  hardware.sane.enable = true;
  hardware.sane.brscan4.enable = true;
  hardware.sane.brscan4.netDevices = {
    "Home" = {
      "ip" = "10.16.1.64";
      "model" = "MFC-9130CW";
    };
  };

  hardware.i2c.enable = true;
  services.ddccontrol.enable = true;
  # pkgs that might be desired
  # ddccontrol-db
  # i2c-tools

  # Enable network discovery
  #services.avahi.enable = true;
  #services.avahi.nssmdns = true;

  # set logitec mouse to autosuspend after 60 seconds
  services.udev.extraRules = ''
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="120000"

ACTION!="add|change", GOTO="yubico_end"

# Udev rules for letting the console user access the Yubikey USB
# device node, needed for challenge/response to work correctly.

# Yubico Yubikey II
ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", \
    ENV{ID_SECURITY_TOKEN}="1"

LABEL="yubico_end"
  '';

  services.pcscd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
