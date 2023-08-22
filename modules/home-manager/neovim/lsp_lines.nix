{pkgs}: {
  plugin = pkgs.vimPlugins.lsp_lines-nvim;
  type = "lua";
  config = ''
    require("lsp_lines").setup()
    -- Disable virtual_text since it's redundant due to lsp_lines.
    vim.diagnostic.config({
      virtual_text = false,
    })
  '';
}
