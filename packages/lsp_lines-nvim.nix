{pkgs}:

let
  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;
  fetchgit = pkgs.fetchgit;
in buildVimPluginFrom2Nix {
  pname = "lsp_lines.nvim";
  version = "2022-06-29";
  meta.homepage = "https://git.sr.ht/~whynothugo/lsp_lines.nvim";
  src = fetchgit {
      url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim";
      rev = "3b57922d2d79762e6baedaf9d66d8ba71f822816";
      sha256 = "1vHMs2Nej/uTancRbo5SNuovE+hxw9fR20pVVfH9UIs=";
  };
}
