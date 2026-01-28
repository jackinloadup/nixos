{ config
, pkgs
, ...
}: {
  config = {
    # for ollama
    hardware.amdgpu.opencl.enable = true;

    networking.hosts = {
      "127.0.0.1" = [
        "ollama.obsidian.home.lucasr.com"
        "chat.obsidian.home.lucasr.com"
      ];
      "0.0.0.0" = [
        "statsig.anthropic.com"
        "statsig.com"
      ];
    };

    services.ollama = {
      enable = true;
      #rocmOverrideGfx = "11.5.1";
      #acceleration = "rocm";
      acceleration = null; # Disable ROCm
      environmentVariables = {
        OLLAMA_ORIGINS = "*";
        OLLAMA_VULKAN = "1"; # Enable Vulkan backend
      };

      openFirewall = true;
      #host = "ollama.obsidian.home.lucasr.com";
      host = "0.0.0.0"; # listen all interfaces
      home = "/var/lib/private/ollama";
      user = "ollama";
      loadModels = [
        "deepseek-r1"
        "llama3.2:1b"
        "codellama"
        "gemma2:27b" # too big
        "devstral-small-2"
      ];

      package = pkgs.unstable.ollama;
    };

    # ollama.home.lucasr.com in mirotik static dns
    services.open-webui = {
      enable = true;
      openFirewall = true;
      port = 11112;
      stateDir = "/var/lib/private/open-webui";
      host = "ollama.obsidian.home.lucasr.com";
      environment = {
        # PYDANTIC_SKIP_VALIDATING_CORE_SCHEMAS = "True";
        OLLAMA_BASE_URL = "http://ollama.obsidian.home.lucasr.com:${toString config.services.ollama.port}";
        ENABLE_OLLAMA_API = "true";
        DEFAULT_USER_ROLE = "user";
        WEBUI_AUTH = "False";
        #WEBUI_AUTH_TRUSTED_EMAIL_HEADER = "X-Webauth-Email";
        #WEBUI_AUTH_TRUSTED_NAME_HEADER = "X-Webauth-Name";
        ENABLE_OAUTH_SIGNUP = "false";
        ENABLE_SIGNUP = "false";
        WEBUI_URL = "https://chat.obsidian.home.lucasr.com";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "false";

        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts."ollama.obsidian.home.lucasr.com" = {
      #forceSSL = true;
      #enableACME = true;
      #acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        #proxyPass = "http://10.16.1.11:${toString config.services.open-webui.port }/";
        proxyPass = "http://localhost:${toString config.services.ollama.port}/";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."chat.obsidian.home.lucasr.com" = {
      #forceSSL = true;
      #enableACME = true;
      #acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        #proxyPass = "http://10.16.1.11:${toString config.services.open-webui.port }/";
        proxyPass = "http://localhost:${toString config.services.open-webui.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
