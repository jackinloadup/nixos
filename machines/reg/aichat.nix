{
  config,
  pkgs,
  ...
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
        #"gemma2:27b" # too big
        "mistral"
        "moondream"
        "starling-lm"
        "solar"
        "llava"
        "llama2-uncensored"
        "phi4"
        "phi3"
      ];

      package = pkgs.unstable.ollama;

      environmentVariables = {
        OLLAMA_ORIGINS = "*";
      };
    };

    # ollama.home.lucasr.com in mirotik static dns
    services.open-webui = {
      enable = true;
      openFirewall = true;
      port = 11112;
      stateDir = "/var/lib/private/open-webui";
      host = "chat.lucasr.com";
      environment = {
        # PYDANTIC_SKIP_VALIDATING_CORE_SCHEMAS = "True";
        OLLAMA_BASE_URL = "http://ollama.home.lucasr.com:${toString config.services.ollama.port}";
        ENABLE_OLLAMA_API = "true";
        DEFAULT_USER_ROLE = "user";
        WEBUI_AUTH = "False";
        #WEBUI_AUTH_TRUSTED_EMAIL_HEADER = "X-Webauth-Email";
        #WEBUI_AUTH_TRUSTED_NAME_HEADER = "X-Webauth-Name";
        ENABLE_OAUTH_SIGNUP = "false";
        ENABLE_SIGNUP = "false";
        WEBUI_URL = "https://chat.lucasr.com";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "false";

        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };
  };
}
