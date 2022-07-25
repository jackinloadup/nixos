{pkgs}: {
  plugin = pkgs.vimPlugins.telescope-nvim;
  type = "lua";
  config = ''
    require('telescope').setup{
    }
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set("n","<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", bufops)
    vim.keymap.set("n","<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", bufops)
    vim.keymap.set("n","<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", bufops)
    vim.keymap.set("n","<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", bufops)
  '';
}
