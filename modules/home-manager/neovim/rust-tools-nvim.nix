{pkgs}: {
  plugin = pkgs.vimPlugins.rust-tools-nvim;
  type = "lua";
  config = ''
    require("rust-tools").setup({})
  '';
}
