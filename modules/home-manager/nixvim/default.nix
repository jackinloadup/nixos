{ config
, pkgs
, ...
}: {
  config = {
    home.packages = [
      # needed to compile treesitter plugins, somewhat guess but works
      pkgs.gcc # should be included automatically
      #pkgs.clang # can't have them both. some kind of namespace collision
    ];

    programs.nixvim = {
      imports = [
        ../../nixvim/full.nix
      ];

      enable = true;
      defaultEditor = true;

      # Home-manager specific: JSON conceallevel (show quotes)
      autoCmd = [
        {
          event = "FileType";
          pattern = [ "json" "jsonc" ];
          command = "setlocal conceallevel=0";
          desc = "Show quotes in JSON files";
        }
      ];

      # Home-manager specific: ollama endpoint uses config.services.ollama.port
      plugins.avante.settings.providers.ollama = {
        endpoint = "http://ollama.home.lucasr.com:${toString config.services.ollama.port}";
        model = "codellama:latest";
        #model = "qwq:32b";
      };
    };
  };
}
