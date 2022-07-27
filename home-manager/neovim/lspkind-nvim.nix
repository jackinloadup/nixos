{pkgs}: {
  plugin = pkgs.vimPlugins.lspkind-nvim;
  type = "lua";
  config = ''
    require("lspkind").init()
  '';
}
