{pkgs}: {
  plugin = pkgs.vimPlugins.indentLine;
  type = "lua";
  # indentLIne uses a feature called conceal. For reasons this hides quotes in
  # json and markdown. The following disables conceal while in insert mode for
  # those file types
  config = ''
    vim.api.nvim_create_autocmd(
        { "InsertEnter" },
        { pattern = { "*.json", "*.md", "*.tex" }, command = "setlocal conceallevel=0" }
    )
    vim.api.nvim_create_autocmd(
        { "InsertLeave" },
        { pattern = { "*.json", "*.md", "*.tex" }, command = "setlocal conceallevel=2" }
    )
  '';
}
