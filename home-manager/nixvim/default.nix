{
  lib,
  config,
  pkgs,
  nixosConfig,
  ...
}: {
  config = {
    programs.nixvim = {
      clipboard.providers.wl-copy.enable = true;
      colorschemes.gruvbox.enable = true;

      plugins.lightline.enable = true;
      plugins.lsp-lines.enable = true;

      plugins.lsp.enable = true;
      plugins.lsp.servers.nixd.enable = true;
      plugins.lsp.servers.rust-analyzer.enable = true;
      plugins.lsp.servers.lua-ls.enable = true;

      plugins.tmux-navigator.enable = true;

      plugins.cmp-treesitter.enable = true;
      plugins.cmp-path.enable = true;
      plugins.cmp-spell.enable = true;
      plugins.cmp-nvim-lua.enable = true;
      plugins.cmp-nvim-lsp.enable = true;
      plugins.copilot-cmp.enable = true;
      plugins.cmp_luasnip.enable = true;

      plugins.cmp-dap.enable = true; # not sure how dap is integrated and used
      plugins.nix.package = true;

      plugins.treesitter.enable = true;

      plugins.rust-tools.enable = true;
    };
  };
}
