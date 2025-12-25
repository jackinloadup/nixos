{ config, lib, pkgs, ... }:
let
  inherit (lib) getExe mkDefault;
in
{
  config = {
    # for ollama
    hardware.amdgpu.opencl.enable = true;

    home-manager.sharedModules = [
      ({ config, ... }: {
        home.packages = [
          # conflicted with k3s, which provides a variation of the package
          #pkgs.kubectl
          pkgs.k3s
          pkgs.istioctl
          pkgs.dbeaver-bin # database gui
          pkgs.claude-monitor # monitor claude use
        ];

        programs.claude-code.enable = true;
        programs.k9s.enable = true; # Kubernetes CLI To Manage Your Clusters In Style

        programs.zoom-us.enable = false; #  didn't work with niri
        programs.firefox.profiles."${config.home.username}".extensions.packages = [
          # automatically select to use zoom in browser
          pkgs.nur.repos.rycee.firefox-addons.zoom-redirector
        ];

        xdg.desktopEntries.gather =
          let
            url = "https://app.v2.gather.town/app/obsidian-3812d4d3-1a3e-4e30-b603-b31c7b22e94f/join";
            icon = builtins.fetchurl {
              url = "https://framerusercontent.com/images/P5hrzskVvpcfIIXVKNXfzAkXLw.png";
              sha256 = "7c089864357290503eafa7ad216d78a6d4118ae70d07683745e1db1c7893e4c2";
            };
            chromium = getExe config.programs.chromium.package;
          in
          {
            name = "Gather";
            genericName = "Gather";
            comment = "Open Gather in a chromeless browser";
            exec = "${pkgs.systemd}/bin/systemd-cat --identifier=gather-browser ${chromium} --app=${url}";
            inherit icon;
            terminal = false;
            categories = [
              "Utility"
            ];
          };
      })
    ];

    networking.hosts = {
      "127.0.0.1" = [
        "ollama.obsidian.home.lucasr.com"
        "chat.obsidian.home.lucasr.com"
      ];
    };

    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%"
        "--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%"
        "--disable=traefik"
      ];
    };

    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = mkDefault true;

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
        OLLAMA_BASE_URL = "http://ollama.home.lucasr.com:${toString config.services.ollama.port}";
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
