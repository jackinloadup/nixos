{lib, nixosConfig, ...}:

with lib;
{
  config = mkIf nixosConfig.machine.impermanence {
    home.persistence."/persist/home/lriutzel" = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "Projects"
        #"VirtualBox VMs"
        "dotfiles"
        ".gnupg"
        ".ssh"
        ".zoom"
        ".cargo"
        ".rustup"
        ".thunderbird"
        ".mozilla"
        #".nixops"
        #".task"
        ".local/share/direnv"
        #".local/share/keyrings"
        ".local/share/lbry"
        #".local/share/MindForger"
        ".local/share/Mumble"
        ".local/share/nvim"
        ".local/share/Steam"
        ".local/share/syncthing"
        ".local/share/wine-nix-profiles"
        ".local/state/pipewire"
        ".local/state/zsh"
        ".config/Signal"
        #".config/@trezor"
        ".config/spotify"
        ".config/LBRY"
        #".config/unity3d" # game saves
        #".config/StardewValley"
        #".config/pipewire"
        #".config/pulse"
        #".config/systemd"
        #".config/kdeconnect"
        #".config/gnome-initial-setup-done"
        #".cache/nix"
        #".cache/mozilla"
        #".cache/chromium"
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
      ];
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
