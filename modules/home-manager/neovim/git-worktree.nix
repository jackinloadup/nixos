{pkgs}: {
  plugin = pkgs.vimPlugins.git-worktree-nvim; # git worktree integration
  type = "lua";
  config = ''
    require("git-worktree").setup()
    require("telescope").load_extension("git_worktree")
    vim.keymap.set("n","<leader>fw", "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", silent)
    vim.keymap.set("n","<leader>fW", "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", silent)
  '';
}
