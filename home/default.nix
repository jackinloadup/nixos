{ config, pkgs, nixosConfig, ... }: 
let
  settings = import ../settings;
in
{
  imports = [
    ./sway.nix
    ./alacritty.nix
    ../common/neovim
  ];

  programs.bash.enable = true;
  programs.bash.initExtra = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';

  programs.home-manager.enable = true;

  home.username = settings.user.username;
  home.homeDirectory = "/home/${settings.user.username}";

  programs.git = {
    enable = true;
    userName = settings.user.name;
    userEmail = settings.user.email;
  };

  
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";

  home.sessionVariables = {
    EDITOR = "vim";
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway"; 
  };

  home.packages = with pkgs; [
    #(aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    curl
    jq
    ripgrep
    rsync
    tree
    mpv
    pavucontrol
  ];
}
