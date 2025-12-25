{ pkgs }:
let
  inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;
  inherit (pkgs) fetchgit;
in
buildVimPluginFrom2Nix {
  pname = "lsp_lines.nvim";
  version = "2022-06-29";
  meta.homepage = "https://git.sr.ht/~whynothugo/lsp_lines.nvim";
  src = fetchgit {
    url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim";
    rev = "dbfd8e96ec2696e1ceedcd23fd70e842256e3dea";
    sha256 = "c+MrWKK7ZIcj2XrPruiQLQ1sr3SJWQfzAR+JM5g+kLE=";
  };
}
