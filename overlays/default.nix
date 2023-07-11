inputs: let
  inherit inputs;
  #cp = f: (super.callPackage f) {};
in
  self: super: {
    # make all unstable packages available;
    unstable = import inputs.nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    #home-assistant = self.unstable.home-assistant.override {
    #  extraPackages = py: with py; [ psycopg2 librouteros ];
    #};
    openrct2 = self.unstable.openrct2;
    obsidian = self.unstable.obsidian;
    rtl_433-dev = super.callPackage ../packages/rtl_433-dev.nix {};

    # use printers ppd file. CUPS 3.0 will eliminate ppd and use ipp everywhere eta ~2023
    mfc9130cwlpr = (super.callPackage ../packages/mfc9130cw.nix {}).driver;
    mfc9130cwcupswrapper = (super.callPackage ../packages/mfc9130cw.nix {}).cupswrapper;

    wrapWine = super.callPackage ../packages/wineWrap.nix {};
    wineApps = {
      winbox = super.callPackage ../packages/winbox.nix {};
      polyhub = super.callPackage ../packages/polyhub.nix {};
    };
    zoom-us = self.unstable.zoom-us;

    # neovim is up to v8 and plugins are good too
    #neovimUtils = self.unstable.neovimUtils;
    #neovim-unwrapped = self.unstable.neovim-unwrapped; # used in home-manager programs.neovim
    ## Vim plugins, added inside existing pkgs.vimPlugins
    #vimPlugins = self.unstable.vimPlugins // {
    #  lsp_lines-nvim = super.callPackage ../packages/lsp_lines-nvim.nix { pkgs = super; };
    #};
  }
