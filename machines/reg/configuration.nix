{ self, inputs, pkgs, lib, ... }:

with inputs;
let
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
    base16.hmModule
  ];

  machine = {
    users = [
      "lriutzel"
    ];
    tui = true;
    sizeTarget = 2;
    autologin-tty1 = true;
    bluetooth = true;
    encryptedRoot = true;
    home-assistant = true;
    gaming = true;
    lowLevelXF86keys.enable = true;
    quietBoot = true;
    simula = true;
    sound = true;
    steam = true;
    sway = true;
  };

  starbase = {
    printerScanner = true;
  };

  networking.hostName = "reg";
  nix.maxJobs = lib.mkDefault 16;

  networking.firewall.allowedTCPPorts = [ 8000 ];
  networking.firewall.allowedUDPPorts = [ 8000 ];

  # Rename pipewire sinks
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

  hardware.i2c.enable = true;
  services.ddccontrol.enable = true;
  # pkgs that might be desired
  # ddccontrol-db
  # i2c-tools
  users.users = with settings.user; {
    ${username} = {
      extraGroups = [ "i2c" ];
    };
  };

  hardware.opengl.extraPackages = with pkgs; [
    radeontop #  Top for amd cards. Could maybe be placed somewhere else? debug only if possible?
  ];

  # set logitec mouse to autosuspend after 60 seconds
  services.udev.extraRules = ''
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c52b", TEST=="power/control", ATTR{power/control}:="auto", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}:="120000"
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
