{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf elem;
  hasOpencode = elem pkgs.opencode config.home.packages;
in
{
  config = mkIf hasOpencode {
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options = {
            baseURL = "http://ollama.home.lucasr.com:11434/v1";
          };
          # Only models with tool/function calling support
          models = {
            "qwen2.5-coder:32b-q4_K_M" = {
              name = "Qwen 2.5 Coder 32B (best for coding)";
            };
            "deepseek-r1" = {
              name = "DeepSeek R1 (reasoning)";
            };
            "ministral-3:8b" = {
              name = "Ministral 3 8B";
            };
            "mistral:7b" = {
              name = "Mistral 7B";
            };
            "llama3.2:1b" = {
              name = "Llama 3.2 1B (fast)";
            };
          };
        };
      };
      model = "ollama/qwen2.5-coder:32b-q4_K_M";
    };
  };
}
