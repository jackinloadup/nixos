inputs:
let
  inherit inputs;
  #cp = f: (super.callPackage f) {};
in self: super: {
  # make all unstable packages available; 
  unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  exodus = self.unstable.exodus;
  blender = self.unstable.blender;
  home-assistant = self.unstable.home-assistant.override {
    extraPackages = py: with py; [ psycopg2 librouteros ];
  };
  steam = self.unstable.steam;
  spotify = self.unstable.spotify;
  lbry = self.unstable.lbry;
  obsidian = self.unstable.obsidian;
  polkit = self.unstable.polkit; # 121 removes spidermonkey
  tor-browser-bundle-bin = self.unstable.tor-browser-bundle-bin;

  # use printers ppd file. CUPS 3.0 will eliminate ppd and use ipp everywhere eta ~2023
  mfc9130cwlpr = (super.callPackage ../packages/mfc9130cw.nix {}).driver;
  mfc9130cwcupswrapper = (super.callPackage ../packages/mfc9130cw.nix {}).cupswrapper;

  wrapWine = super.callPackage ../packages/wineWrap.nix {};
  wineApps = {
    winbox = super.callPackage ../packages/winbox.nix {};
    polyhub = super.callPackage ../packages/polyhub.nix {};
  };
  taskwarrior = self.unstable.taskwarrior;
  zoom-us = self.unstable.zoom-us;

  neovimUtils = self.unstable.neovimUtils;
  neovim-unwrapped = self.unstable.neovim-unwrapped; # used in home-manager programs.neovim
  # Vim plugins, added inside existing pkgs.vimPlugins
  vimPlugins = self.unstable.vimPlugins // {
    lsp_lines-nvim = super.callPackage ../packages/lsp_lines-nvim.nix { pkgs = super; };
  };
}
