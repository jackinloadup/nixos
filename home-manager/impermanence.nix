{ inputs, pkgs, config, lib, nixosConfig, ... }:

let
  inherit (lib) mkIf optionals;
  username = config.home.username;
in {
  imports = [
    (import "${inputs.impermanence}/home-manager.nix")
  ];

  config = mkIf nixosConfig.machine.impermanence {
    home.persistence."/persist/home/${username}" = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "Projects"
        #"VirtualBox VMs"
        "dotfiles"
        ".ssh"
        ".cargo"
        ".kube"
        ".rustup"
        ".thunderbird"
        ".password-store"
        #".nixops"
        #".task"
        ".local/share/direnv"
        #".local/share/keyrings"
        ".local/share/lbry"
        ".local/share/MindForger"
        ".local/share/Mumble"
        ".local/share/nvim"
        ".local/share/Steam"
        ".local/share/wine-nix-profiles"
        ".local/state/pipewire"
        ".local/state/wireplumber"
        ".local/state/zsh"
        ".local/state/bash"
        ".config/libreoffice"
        ".config/Signal"
        #".config/@trezor"
        ".config/spotify"
        ".config/LBRY"
        ".config/ghb" # handbrake
        ".config/kvibes" # MediaElch
        ".config/OpenRCT2" # MediaElch
        #".config/unity3d" # game saves
        #".config/StardewValley"
        #".config/pipewire"
        #".config/pulse"
        #".config/systemd"
        #".config/kdeconnect"
        #".config/gnome-initial-setup-done"
        #".cache/nix"
        #".cache/fractal"
        #".cache/vulnix"
        #".cache/wine"
        #".cache/vulnix"
        #".cache/nix"
        #".cache/nix-index"
        #".cache/tealdeer"
        #".cache/thunderbird"
        ##".cache/tracker3" # for gnome 
        #".cache/fontconfig"
        #".cache/vulnix"
        #".cache/vulnix"
      ]
      ++ optionals config.services.syncthing.enable [ 
        ".local/share/syncthing"
        ".config/syncthing"
      ]
      ++ optionals nixosConfig.programs.chromium.enable [ ".cache/chromium" ]
      ++ optionals config.programs.gpg.enable [ ".gnupg" ]
      ++ optionals config.programs.firefox.enable [ ".mozilla" ]
      ++ optionals config.programs.zoom-us.enable [ ".zoom" ];

      files = [
        ".lftp/rc"
        ".bash_history"
        ".steam/registry.vdf"
        #".screenrc"
      ];
      allowOther = true;
    };
  };
}
