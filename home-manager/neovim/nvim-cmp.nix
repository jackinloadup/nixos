{pkgs}: {
  plugin = pkgs.vimPlugins.nvim-cmp;
  type = "lua";
  config = ''
  local cmp = require("cmp")

  cmp.setup({
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "buffer" },
    })
  })
  '';
}
