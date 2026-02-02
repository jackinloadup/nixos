{ config, flake, lib, ... }:
let
  inherit (lib) mergeAttrsList mkIf;
  inherit (builtins) filter elem;

  selfLib = import ./lib/secrets.nix { };
  inherit (selfLib) smachines shostHasService;

  hostname = config.networking.hostName;

  servers = [ "marulk" ];
  lucasDevHosts = [ "reg" "riko" ];

  mkWgHost = host: {
    "wg-vpn-${host}" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/wg-vpn/private.age;
    };
  };
  wgHosts = filter (host: shostHasService host "wg-vpn") smachines;
  wgHostsConfig = mergeAttrsList (map mkWgHost wgHosts);

  mkNebulaHost = host: {
    "nebula-${host}-cert" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/nebula/host.crt.age;
      mode = "660";
      owner = "nebula-gumdrop";
      group = "nebula-gumdrop";
    };
    "nebula-${host}-key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/nebula/host.key.age;
      mode = "660";
      owner = "nebula-gumdrop";
      group = "nebula-gumdrop";
    };
  };
  nebulaHosts = filter (host: shostHasService host "nebula") smachines;
  nebulaHostsConfig = mergeAttrsList (map mkNebulaHost nebulaHosts);

  # Nebula CA cert - shared across all nebula hosts
  nebulaCAConfig = {
    nebula-ca = mkIf (elem hostname nebulaHosts) {
      file = ./secrets/services/nebula/ca.crt.age;
      owner = "nebula-gumdrop";
      group = "nebula-gumdrop";
    };
  };

  mkTorHost = host: {
    "tor-service-${host}-hostname" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/tor-service/hostname.age;
    };
    "tor-service-${host}-hs_ed25519_public_key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/tor-service/hs_ed25519_public_key.age;
    };
    "tor-service-${host}-hs_ed25519_secret_key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/tor-service/hs_ed25519_secret_key.age;
    };
  };
  torHosts = filter (host: shostHasService host "tor-service") smachines;
  torHostsConfig = mergeAttrsList (map mkTorHost torHosts);

  # ssh host private keys aren't stored here and public keys are not encrypted
  mkSshdHost = host: {
    "sshd-${host}-private-key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/sshd/private_key.age;
    };
  };
  sshdHosts = filter (host: shostHasService host "sshd") smachines;
  sshdHostsConfig = mergeAttrsList (map mkSshdHost sshdHosts);

  mkInitSshdHost = host: {
    "init-sshd-${host}-private-key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/init-sshd/private_key.age;
    };
  };
  initSshdHosts = filter (host: shostHasService host "init-sshd") smachines;
  initSshdHostsConfig = mergeAttrsList (map mkInitSshdHost initSshdHosts);

in
{
  imports = [
    flake.inputs.ragenix.nixosModules.default
  ];

  config = {
    age.secrets = {
      commonPass = {
        file = ./secrets/commonPass.age;
      };

      lyza-frigate = mkIf (elem hostname [ "lyza" ]) {
        file = ./secrets/machines/lyza/frigate/environment.age;
      };

      system-wireless-networking = {
        file = ./secrets/system/wireless-networking.age;
      };

      immich = mkIf (elem hostname servers) {
        file = ./secrets/services/immich/secretsFile;
        path = "/run/secrets/immich";
        mode = "770";
        owner = "immich";
        group = "immich";
      };

      immich-api-key = mkIf (elem hostname servers) {
        file = ./secrets/services/immich/api-key.age;
        owner = "immich";
        group = "immich";
      };

      namecheap-api-user = mkIf (elem hostname servers) {
        file = ./secrets/services/namecheap/api-user.age;

      };

      namecheap-api-key = mkIf (elem hostname servers) {
        file = ./secrets/services/namecheap/api-key.age;
      };

      nextcloud-db-pass = mkIf (elem hostname servers) {
        file = ./secrets/services/nextcloud/db-pass.age;
        owner = "nextcloud";
        group = "nextcloud";
      };

      vaultwarden-env = mkIf (elem hostname servers) {
        file = ./secrets/services/vaultwarden/env.age;
        owner = "vaultwarden";
        group = "vaultwarden";
      };

      gmail-smtp-password = mkIf (elem hostname servers) {
        file = ./secrets/services/gmail/smtp-password.age;
      };

      kanidm-admin-password = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/admin-password.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-idm-admin-password = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/idm-admin-password.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-oidc-nextcloud = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-nextcloud.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-oidc-jellyfin = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-jellyfin.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-oidc-immich = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-immich.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-oidc-paperless = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-paperless.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-oidc-grafana = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-grafana.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-oidc-open-webui = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-open-webui.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-oidc-audiobookshelf = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-audiobookshelf.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
      kanidm-oidc-forgejo = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-forgejo.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0440";
      };
      # Forgejo needs to read the OIDC secret for OAuth setup
      forgejo-oidc-secret = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-forgejo.age;
        owner = "forgejo";
        group = "forgejo";
        mode = "0400";
      };

      # Grafana needs to read its OIDC secret
      grafana-oidc-secret = mkIf (elem hostname servers) {
        file = ./secrets/services/kanidm/oidc-grafana.age;
        owner = "grafana";
        group = "grafana";
        mode = "0400";
      };

      # Open-WebUI OIDC environment file (on machines running open-webui)
      open-webui-oidc-env = mkIf (elem hostname [ "reg" "obsidian" ]) {
        file = ./secrets/services/open-webui/oidc-env.age;
      };

      paperless-oidc-env = mkIf (elem hostname servers) {
        file = ./secrets/services/paperless/oidc-env.age;
        owner = "paperless";
        group = "paperless";
        mode = "0400";
      };

      nix-signing-key = mkIf (elem hostname servers) {
        file = ./secrets/services/nix/signing-key.age;
      };

      nix-signing-pub-key = mkIf (elem hostname servers) {
        file = ./secrets/services/nix/signing-key.pub.age;
      };

      forgejo-runner-token = mkIf (elem hostname servers) {
        file = ./secrets/services/forgejo/runner-token.age;
      };

      hydra-builder-ssh-key = mkIf (elem hostname servers) {
        file = ./secrets/services/hydra/builder-ssh-key.age;
        path = "/var/lib/hydra/queue-runner/.ssh/id_ed25519";
        owner = "hydra-queue-runner";
        group = "hydra";
        mode = "0600";
      };

      # Same key but root-owned for nix-daemon git fetches
      hydra-builder-ssh-key-root = mkIf (elem hostname servers) {
        file = ./secrets/services/hydra/builder-ssh-key.age;
        path = "/etc/nix/hydra-builder-ssh-key";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      # Forgejo access token for nix git fetches over HTTPS
      hydra-forgejo-token = mkIf (elem hostname servers) {
        file = ./secrets/services/hydra/forgejo-token.age;
      };

      lriutzel-hashed-password = {
        file = ./secrets/users/lriutzel/hashed-password.age;
      };

      lriutzel-aws-beautyfromlight-key-id = mkIf (elem hostname lucasDevHosts) {
        file = ./secrets/users/lriutzel/aws-beautyfromlight-key_id.age;
      };

      lriutzel-aws-beautyfromlight-access-key = mkIf (elem hostname lucasDevHosts) {
        file = ./secrets/users/lriutzel/aws-beautyfromlight-access_key.age;
      };

      criutzel-hashed-password = {
        file = ./secrets/users/criutzel/hashed-password.age;
      };

      briutzel-hashed-password = {
        file = ./secrets/users/briutzel/hashed-password.age;
      };

      serviceftp-hashed-password = {
        file = ./secrets/users/serviceftp/hashed-password.age;
      };
    }
    // initSshdHostsConfig
    // sshdHostsConfig
    // torHostsConfig
    // wgHostsConfig
    // nebulaHostsConfig
    // nebulaCAConfig;
  };
}
