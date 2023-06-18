{pkgs}: {
  plugin = pkgs.vimPlugins.wilder-nvim;
  type = "lua";
  config = ''
    local wilder = require("wilder")
    wilder.setup({modes = {':', '/', '?'}})
  '';
}
