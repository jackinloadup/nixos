{
  flake,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf optionals;
  username = config.home.username;
in {
  imports = [
    flake.inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  config = {
    home.persistence."/persist/home/${username}" = {
      directories =
        [
          "Desktop"
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "Projects"
          #"VirtualBox VMs"
          #".ssh" # locally managed. home-manager does have module
          #".nixops"

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
          ".config/dconf" # setting is at the system level programs.dconf.enable
          ".config/libreoffice"
          ".config/Signal"
          ".config/spotify"
          ".config/LBRY"
          ".config/ghb" # handbrake
          ".config/kvibes" # MediaElch
          ".config/OpenRCT2" # MediaElch
          ".cache/huggingface" # todo pull in from nixified-ai
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
        #++ optionals nixosConfig.programs.steam.enable [".local/share/Steam"]
        #++ optionals nixosConfig.services.trezord.enable [".config/@trezor"]
        #++ optionals nixosConfig.services.pipewire.enable [".local/state/pipewire" ".local/state/wireplumber"]
        ++ [".local/share/Steam"]
        ++ [".config/@trezor"]
        ++ [".local/state/pipewire" ".local/state/wireplumber"]
        ++ optionals config.programs.chromium.enable [".config/chromium" ".cache/chromium"]
        ++ optionals config.programs.neovim.enable [".local/share/nvim"]
        ++ optionals config.programs.direnv.enable [".local/share/direnv" ".cache/direnv"]
        ++ optionals config.programs.gpg.enable [".gnupg"]
        ++ optionals config.programs.firefox.enable [".mozilla" ".cache/mozilla"]
        ++ optionals config.programs.thunderbird.enable [".thunderbird" ".cache/thunderbird"]
        ++ optionals config.programs.zoom-us.enable [".zoom"]
        ++ optionals config.programs.zsh.enable [".local/state/zsh"]
        ++ optionals config.services.syncthing.enable [
          ".local/share/syncthing"
          ".config/syncthing"
        ];

      #files =
      #  [
      #    ".lftp/rc"
      #    ".bash_history"
      #    ".local/state/z"
      #    #".screenrc"
      #    ".steam/registry.vdf"
      #  ];
        #++ optionals nixosConfig.programs.steam.enable [".steam/registry.vdf"];
      allowOther = true;
    };
  };
}
