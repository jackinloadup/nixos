{
  inputs,
  pkgs,
  config,
  lib,
  nixosConfig,
  ...
}: let
  inherit (lib) mkIf optionals;
  username = config.home.username;
in {
  imports = [
    (import "${inputs.impermanence}/home-manager.nix")
  ];

  config = mkIf nixosConfig.machine.impermanence {
    home.persistence."/persist/home/${username}" = {
      directories =
        [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "Projects"
          #"VirtualBox VMs"
          #".ssh" # locally managed. home-manager does have module
          ".cargo"
          ".kube"
          ".rustup"
          ".password-store"
          #".nixops"
          #".task"
          #".local/share/keyrings"
          ".local/share/nix"
          ".local/share/lbry"
          ".local/share/MindForger"
          ".local/share/mopidy"
          ".local/share/Mumble"
          ".local/share/PrismLauncher"
          ".local/share/wine-nix-profiles"
          ".local/share/invokeai" # todo pull in from nixified-ai
          ".local/state/bash"
          ".config/discord"
          ".config/dconf"
          ".config/libreoffice"
          ".config/github-copilot"
          ".config/nwg-panel"
          ".config/Signal"
          ".config/spotify"
          ".config/LBRY"
          ".config/ghb" # handbrake
          ".config/kvibes" # MediaElch
          ".config/OpenRCT2" # MediaElch
          ".cache/huggingface" # todo pull in from nixified-ai
          #".cache/mozilla"
          #".config/unity3d" # game saves
          #".config/StardewValley"
          #".config/systemd"
          #".config/kdeconnect"
          #".config/gnome-initial-setup-done"
          #".cache/fractal"
          #".cache/vulnix"
          #".cache/wine"
          #".cache/nix"
          #".cache/nix-index"
          #".cache/tealdeer"
          #".cache/tracker3" # for gnome
          #".cache/fontconfig"
          #".cache/vulnix"
        ]
        ++ optionals nixosConfig.programs.chromium.enable [".cache/chromium"]
        ++ optionals nixosConfig.programs.steam.enable [".local/share/Steam"]
        ++ optionals nixosConfig.services.trezord.enable [".config/@trezor"]
        ++ optionals nixosConfig.services.pipewire.enable [".local/state/pipewire" ".local/state/wireplumber"]
        ++ optionals config.programs.neovim.enable [".local/share/nvim"]
        ++ optionals config.programs.direnv.enable [".local/share/direnv" ".cache/direnv"]
        ++ optionals config.programs.gpg.enable [".gnupg"]
        ++ optionals config.programs.firefox.enable [".mozilla"]
        ++ optionals config.programs.thunderbird.enable [".thunderbird" ".cache/thunderbird"]
        ++ optionals config.programs.zoom-us.enable [".zoom"]
        ++ optionals config.programs.zsh.enable [".local/state/zsh"]
        ++ optionals config.services.syncthing.enable [
          ".local/share/syncthing"
          ".config/syncthing"
        ];

      files =
        [
          ".lftp/rc"
          ".bash_history"
          ".local/state/z"
          #".screenrc"
        ]
        ++ optionals nixosConfig.programs.steam.enable [".steam/registry.vdf"];
      allowOther = true;
    };
  };
}
