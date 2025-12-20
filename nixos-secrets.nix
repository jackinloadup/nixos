{ config, flake, lib, ... }:
let
  inherit (lib) attrNames mergeAttrsList mkIf;
  inherit (builtins) readDir filter elem;

  selfLib = import ./lib/secrets.nix { };
  inherit (selfLib) smachines shostHasService;

  hostname = config.networking.hostName;

  servers = [ "marulk" ];
  lucasDevHosts = [ "reg" "riko" ];

  mkWgHost = (host: {
    "wg-vpn-${host}" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/wg-vpn/private.age;
    };
  });
  wgHosts = filter (host: shostHasService host "wg-vpn") smachines;
  wgHostsConfig = mergeAttrsList (map mkWgHost wgHosts);

  mkTorHost = (host: {
    "tor-service-${host}-hostname" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/tor-service/hostname.age;
    };
    "tor-service-${host}-hs_ed25519_public_key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/tor-service/hs_ed25519_public_key.age;
    };
    "tor-service-${host}-hs_ed25519_secret_key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/tor-service/hs_ed25519_secret_key.age;
    };
  });
  torHosts = filter (host: shostHasService host "tor-service") smachines;
  torHostsConfig = mergeAttrsList (map mkTorHost torHosts);

  # ssh host private keys aren't stored here and public keys are not encrypted
  mkSshdHost = (host: {
    "sshd-${host}-private-key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/sshd/private_key.age;
    };
  });
  sshdHosts = filter (host: shostHasService host "sshd") smachines;
  sshdHostsConfig = mergeAttrsList (map mkSshdHost sshdHosts);

  mkInitSshdHost = (host: {
    "init-sshd-${host}-private-key" = mkIf (hostname == host) {
      file = ./secrets/machines/${host}/init-sshd/private_key.age;
    };
  });
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

      nix-signing-key = mkIf (elem hostname servers) {
        file = ./secrets/services/nix/signing-key.age;
      };

      nix-signing-pub-key = mkIf (elem hostname servers) {
        file = ./secrets/services/nix/signing-key.pub.age;
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
    // wgHostsConfig;
  };
}
