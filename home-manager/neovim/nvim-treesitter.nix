{pkgs}: {
  plugin = (pkgs.vimPlugins.nvim-treesitter.withPlugins (
    # The following plugins come from here
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/tools/parsing/tree-sitter/update.nix
    plugins: with plugins; [
      # from tree-sitter github org
      tree-sitter-html
      tree-sitter-css
      tree-sitter-bash
      tree-sitter-javascript
      tree-sitter-typescript
      tree-sitter-json
      tree-sitter-python
      tree-sitter-toml
      tree-sitter-rust
      tree-sitter-php

      # other repos
      tree-sitter-nix
      tree-sitter-make
      tree-sitter-markdown
      tree-sitter-lua
      tree-sitter-vim
      tree-sitter-yaml
      tree-sitter-dockerfile
      tree-sitter-scss
    ]
  ));
  type = "lua";
  config = ''
require'nvim-treesitter.configs'.setup {
  -- https://github.com/nvim-treesitter/nvim-treesitter

  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  -- ensure_installed = { 'bash', 'html', 'javascript', 'json', 'lua', 'python', 'toml', 'yaml', 'rust', 'vim', 'css', 'scss', 'nix', 'php' },
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing for "all"
  highlight = {
    enable = true,              -- false will disable the whole extension

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },  -- list of language that will be disabled

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true
  }
}
  '';
}
