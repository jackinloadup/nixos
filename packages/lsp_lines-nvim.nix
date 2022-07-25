{pkgs, system}:

buildVimPluginFrom2Nix {
    pname = "lsp_lines.nvim";
    version = "2022-06-29";
    meta.homepage = "https://git.sr.ht/~whynothugo/lsp_lines.nvim";
    src = fetchgit {
        url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim";
        rev = "3b57922d2d79762e6baedaf9d66d8ba71f822816";
        #sha256 = "12i9v3vnbl0djx43y46xli3f5nbf2yly4c7d0mcq8682yxfq149b";
    };
  };
