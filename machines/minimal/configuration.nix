{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
with inputs; let
  inherit (lib) mkIf mkDefault mkForce mkSetuidRoot;
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  machine = {
    users = [
      #      "lriutzel"
    ];
    tui = false;
    sizeTarget = 0;
    encryptedRoot = false;
    lowLevelXF86keys.enable = false;
    windowManagers = [];
    minimal = true;
  };

  networking.hostName = "minimal";
  nix.settings.max-jobs = lib.mkDefault 2;

  networking.networkmanager.enable = mkForce false;
  #security.wrappers.fusermount = mkForce null;
  #security.wrappers = builtins.removeAttrs config.security.wrappers [ "fusermount" ];

  security.wrappers = let
    mkSetuidRoot = source: {
      setuid = true;
      owner = "root";
      group = "root";
      inherit source;
    };
  in
    mkForce {
      mount = mkSetuidRoot "${lib.getBin pkgs.util-linux}/bin/mount";
      umount = mkSetuidRoot "${lib.getBin pkgs.util-linux}/bin/umount";
    };

  environment.noXlibs = mkDefault true;
  environment.defaultPackages = mkForce [];

  boot.enableContainers = false;
  xdg.mime.enable = false;
  xdg.icons.enable = false;
  xdg.menus.enable = false;
  xdg.sounds.enable = false;
  xdg.autostart.enable = false;
  powerManagement.cpuFreqGovernor = mkForce null;

  hardware.enableAllFirmware = mkForce false;
  hardware.enableRedistributableFirmware = mkForce false;
  i18n.supportedLocales = ["en_US.UTF-8/UTF-8"];
  programs.command-not-found.enable = mkDefault false;

  services.timesyncd.enable = false; # systemdMinimal doesn't have timesyncd
  nix.enable = false;
  system.disableInstallerTools = true;
  systemd = {
    # if using just systemdMinimal mods will need to be done to work.
    # following command builds result
    # sudo nix build --override-input nixpkgs ~/Projects/nixpkgs ./dotfiles#nixosConfigurations.minimal.config.system.build.toplevel                                                                                                ~ took 15s
    package = pkgs.systemdMinimal;
    #package = pkgs.systemdMinimal.override {
    #  withCoredump = true;
    #  withCompression = true;
    #  withLogind = true;
    #};
    services = {
      nix-daemon.enable = false;
      mount-pstore.enable = false;
      sysctl.enable = false;
      journald.enable = false;
      user-sessions.enable = false;
      shutdownRamfs.enable = false;
    };
    sockets.nix-daemon.enable = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
