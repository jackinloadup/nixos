{ inputs, pkgs, ... }: 

with inputs;
let
  settings = import ../settings;
in
{
  imports = [
    ./sway.nix
    ./alacritty.nix
    ../common/neovim
    base16.hmModule
  ];

  config = {
  nixpkgs.config.allowUnfree = true;

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


  #source ${config.lib.base16.templateFile { name = "shell"; }}
  programs.bash.enable = true;
  programs.bash.initExtra = ''

    # if tty1 then dont fork, instead transfer execution to sway
    # thus if sway crashes the resulting terminal will not be logged in
    [[ "$(tty)" == /dev/tty1 ]] && exec sway
  '';

  programs.home-manager.enable = true;

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
    XDG_SESSION_TYPE = "wayland";
    NVIM_TUI_ENABLE_TRUE_COLOR = 1;
    NVIM_TUI_ENABLE_CURSOR_SHAPE = 2; # blink cursor maybe? https://github.com/neovim/neovim/pull/5977
  };

  home.username = settings.user.username;
  home.homeDirectory = "/home/${settings.user.username}";

  home.packages = with pkgs; [
    #(aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    mpv # media player
    pavucontrol # GUI volume source/sink manager
    zathura # PDF / Document viewer
    libreoffice # Office suite
    fractal # matrix client
    thunderbird # Email client
    firefox # Web browser
    tixati # bittorrent client
    mumble # voice chat application
    spotify-tui # music player w/ spotify subscription
    spotifyd

    bitwarden-cli

    tor-browser-bundle-bin

    gnome.simple-scan

    xfce.thunar
    #pantheon.elementary-files

  ];
};
}
