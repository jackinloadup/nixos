{ pkgs, lib, inputs, ... }:
let
  inherit (lib) mkDefault mkForce;
in
{
  imports = [
    inputs.self.nixosModules.default
    inputs.self.nixosModules.lriutzelTui
    ./hardware-configuration.nix
    ./iwd.nix
  ];

  boot.plymouth.enable = true;
  #boot.plymouth.themePackages = [ pkgs.adi1090x-plymouth-themes ];
  #boot.plymouth.theme = "colorful";

  ## plymouth alternative themes
  # colorful
  # colorful-loop
  # colorful-hud
  # owl
  # pixels
  # Polaroid
  # Rings-2
  # Sphere

  boot.initrd.verbose = false;

  hardware.bluetooth.enable = true;
  hardware.yubikey.enable = mkDefault true;

  services.pipewire.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "criutzel";
  services.displayManager.defaultSession = "gnome";
  services.displayManager.gdm.enable = true;

  services.desktopManager.gnome.enable = true;
  #services.xserver.windowManager.i3.enable = true;

  machine = {
    users = [ "lriutzel" "criutzel" ];
    tui = true;
    sizeTarget = 2;
    lowLevelXF86keys.enable = true;
    impermanence = true;
  };

  gumdrop = {
    printerScanner = true;
    storageServer.enable = true;
    storageServer.media = true;
    storageServer.roms = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
