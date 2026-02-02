{ config
, pkgs
, ...
}: {
  config = {
    # ollama.home.lucasr.com in mirotik static dns
    services.ollama = {
      enable = true;
      rocmOverrideGfx = "11.0.0"; ## rdna 3 11.0.0
      acceleration = "rocm";
      openFirewall = true;
      host = "ollama.home.lucasr.com";
      home = "/var/lib/private/ollama";
      user = "ollama";
      loadModels = [
        "deepseek-r1"
        "llama3.2:1b"
        "codellama"
        "gemma2:9b"
        "dolphin3"
        "ministral-3:8b"
        "mistral:7b"
        "deepseek-coder-v2:16b"
        "qwen2.5-coder:32b-q4_K_M"
      ];

      package = pkgs.unstable.ollama;

      environmentVariables = {
        OLLAMA_ORIGINS = "*";
        OLLAMA_NUM_GPU = "999"; # Use max GPU layers possible
        OLLAMA_GPU_MEMORY_FRACTION = "0.9"; # Use 90% of VRAM
      };
    };

    # ollama.home.lucasr.com in mirotik static dns
    services.open-webui = {
      enable = true;
      openFirewall = true;
      port = 11112;
      stateDir = "/var/lib/private/open-webui";
      host = "ollama.home.lucasr.com";
      environment = {
        OLLAMA_BASE_URL = "http://ollama.home.lucasr.com:${toString config.services.ollama.port}";
        ENABLE_OLLAMA_API = "true";
        DEFAULT_USER_ROLE = "user";

        # Kanidm OIDC authentication
        WEBUI_AUTH = "True";
        ENABLE_OAUTH_SIGNUP = "true";
        OAUTH_PROVIDER_NAME = "Kanidm";
        OAUTH_CLIENT_ID = "open-webui";
        OPENID_PROVIDER_URL = "https://auth.lucasr.com/oauth2/openid/open-webui/.well-known/openid-configuration";
        OAUTH_SCOPES = "openid profile email";
        ENABLE_LOGIN_FORM = "false";
        ENABLE_SIGNUP = "false";
        WEBUI_URL = "https://chat.lucasr.com";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "true";

        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
      # OIDC client secret from agenix
      environmentFile = config.age.secrets.open-webui-oidc-env.path;
    };
  };
}
