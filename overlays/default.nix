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
  nixos-shell = self.unstable.nixos-shell; # needed for 0.2.2
  nmap-graphical = self.unstable.nmap-graphical;
  neovim-unwrapped = self.unstable.neovim-unwrapped;
  home-assistant = self.unstable.home-assistant.override {
    extraPackages = py: with py; [ psycopg2 librouteros ];
  };
  steam = self.unstable.steam;
  spotify = self.unstable.spotify;
  lbry = self.unstable.lbry;
  obsidian = self.unstable.obsidian;
  polkit = self.unstable.polkit; # 121 removes spidermonkey

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
  ## Example package, used only for tests
  #hello-custom = super.callPackage ../packages/hello-custom { };
  #darktile = super.callPackage ../packages/darktile { };

  ## Custom packages. Will be made available on all machines and used where
  ## needed.
  #wezterm-bin = super.callPackage ../packages/wezterm-bin { };
  #wezterm-nightly = super.callPackage ../packages/wezterm-nightly { };
  #filebrowser = super.callPackage ../packages/filebrowser { };
  #zk = super.callPackage ../packages/zk { };

  # Vim plugins, added inside existing pkgs.vimPlugins
  vimPlugins = super.vimPlugins // {
    lsp_lines-nvim = super.callPackage ../packages/lsp_lines-nvim.nix { pkgs = super; };
    #indent-blankline-nvim-lua =
    #  super.callPackage ../packages/indent-blankline-nvim-lua {
    #    inputs = inputs;
    #  };
    #zk-nvim = super.callPackage ../packages/zk-nvim { inputs = inputs; };
    #nvim-fzf = super.callPackage ../packages/nvim-fzf { inputs = inputs; };
  };

  ## ZSH plugins
  #zsh-abbrev-alias =
  #  super.callPackage ../packages/zsh-abbrev-alias { inputs = inputs; };
  #zsh-colored-man-pages =
  #  super.callPackage ../packages/zsh-colored-man-pages { inputs = inputs; };

  #forgit =
  #  super.callPackage ../packages/forgit { inputs = inputs; };
}
