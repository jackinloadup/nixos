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

    stable = import inputs.nixpkgs-stable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    # module no updated with package, breaking stats
    #https://github.com/NixOS/nixpkgs/issues/391383
    #
    #frigate = self.unstable.frigate;

    # All for 8BitDuo support. TODO remove - 2-25
    # merged, can be removed soonish
    # https://github.com/libretro/retroarch-joypad-autoconfig/pull/1224
    retroarch-joypad-autoconfig = super.retroarch-joypad-autoconfig.overrideAttrs {
      src = super.fetchFromGitHub {
        owner = "JonSnow88";
        repo = "retroarch-joypad-autoconfig";
        rev = "1861d153e5d14cbd4f7ab60495a75cd631005ef5";
        hash = "sha256-xwro/YXl5g520YLF6WLpgaLkCgU58vpmF2kgxd5EL78=";
      };
    };

    #ubpm = super.ubpm.overrideAttrs {
    #  #version = "1.13.0";
    #  version = "1.12.0";
    #  patches = [];
    #  nativeBuildInputs = super.ubpm.nativeBuildInputs ++ [
    #    super.pkg-config
    #  ];
    #  buildInputs = super.ubpm.buildInputs ++ [
    #    super.udev
    #  ];

    #  src = super.fetchFromGitea {
    #    domain = "codeberg.org";
    #    owner = "LazyT";
    #    repo = "ubpm";
    #    #rev = "1.13.0";
    #    #hash = "sha256-Hw0QWf1vnJlR7tP5rZjdo4amYN1uxoKv9jxxkBdlJQs=";
    #    rev = "1.12.0";
    #    hash = "sha256-Hw0QWf1vnJlR7tP5rZjdo4amYN1uxoKv9jxxkBdlJQs=";
    #  };
    #};
    #home-assistant = self.unstable.home-assistant.override {
    #  extraPackages = py: with py; [ psycopg2 librouteros ];
    #};
    waytrogen = self.unstable.waytrogen;
    openrct2 = self.unstable.openrct2;
    obsidian = self.unstable.obsidian;
    bark = self.unstable.bark;
    rtl_433-dev = super.callPackage ../packages/rtl_433-dev.nix {};

    ragenix = inputs.ragenix.packages."x86_64-linux".default;

    # update in unstable broke b/c of schema version mismatch in config file
    adguardhome = self.stable.adguardhome;
    #j4-dmenu-desktop = self.stable.j4-dmenu-desktop;
    snes9x-gtk = self.stable.snes9x-gtk;

    # use printers ppd file. CUPS 3.0 will eliminate ppd and use ipp everywhere eta ~2023
    mfc9130cwlpr = (super.callPackage ../packages/mfc9130cw.nix {}).driver;
    mfc9130cwcupswrapper = (super.callPackage ../packages/mfc9130cw.nix {}).cupswrapper;

    wrapWine = super.callPackage ../packages/wineWrap.nix {};
    wineApps = {
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
