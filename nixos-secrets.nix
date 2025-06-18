{ flake, lib, ... }:
let
  inherit (lib) attrNames mergeAttrsList;
  inherit (builtins) readDir filter;

  selfLib = import ./lib/secrets.nix {};
  inherit (selfLib) smachines shostHasService;

  mkWgHost = (host: {
     "wg-vpn-${host}" = {
        file = ./secrets/machines/${host}/wg-vpn/private.age;
     };
  });
  wgHosts = filter (host: shostHasService host "wg-vpn") smachines;
  wgHostsConfig = mergeAttrsList (map mkWgHost wgHosts);

  mkTorHost = (host: {
     "tor-service-${host}-hostname" = {
        file = ./secrets/machines/${host}/tor-service/hostname.age;
     };
     "tor-service-${host}-hs_ed25519_public_key" = {
        file = ./secrets/machines/${host}/tor-service/hs_ed25519_public_key.age;
     };
     "tor-service-${host}-hs_ed25519_secret_key" = {
        file = ./secrets/machines/${host}/tor-service/hs_ed25519_secret_key.age;
     };
  });
  torHosts = filter (host: shostHasService host "tor-service") smachines;
  torHostsConfig = mergeAttrsList (map mkTorHost torHosts);

  # ssh host private keys aren't stored here and public keys are not encrypted
  mkSshdHost = (host: {
    "sshd-${host}-private-key" = {
      file = ./secrets/machines/${host}/sshd/private_key.age;
    };
  });
  sshdHosts = filter (host: shostHasService host "sshd") smachines;
  sshdHostsConfig = mergeAttrsList (map mkSshdHost sshdHosts);

  mkInitSshdHost = (host: {
    "init-sshd-${host}-private-key" = {
      file = ./secrets/machines/${host}/init-sshd/private_key.age;
    };
  });
  initSshdHosts = filter (host: shostHasService host "init-sshd") smachines;
  initSshdHostsConfig = mergeAttrsList (map mkInitSshdHost initSshdHosts);

in {
  imports = [
    flake.inputs.ragenix.nixosModules.default
  ];

  config = {
    age.secrets = {
      commonPass = {
        file = ./secrets/commonPass.age;
      };

      system-wireless-networking = {
        file = ./secrets/system/wireless-networking.age;
      };

      immich = {
        file = ./secrets/services/immich/secretsFile;
        path = "/run/secrets/immich";
        mode = "770";
        owner = "immich";
        group = "immich";
      };

      namecheap-api-user = {
        file = ./secrets/services/namecheap/api-user.age;

      };

      namecheap-api-key = {
        file = ./secrets/services/namecheap/api-key.age;
      };

      nextcloud-db-pass = {
        file = ./secrets/services/nextcloud/db-pass.age;
        owner = "nextcloud";
        group = "nextcloud";
      };

      wg-vpn-marulk = {
        file = ./secrets/machines/marulk/wg-vpn/private.age;
      };

      wg-vpn-reg = {
        file = ./secrets/machines/reg/wg-vpn/private.age;
      };

      wg-vpn-riko = {
        file = ./secrets/machines/riko/wg-vpn/private.age;
      };

      nix-signing-key = {
        file = ./secrets/services/nix/signing-key.age;
      };

      nix-signing-pub-key = {
        file = ./secrets/services/nix/signing-key.pub.age;
      };

      lriutzel-hashed-password = {
        file = ./secrets/users/lriutzel/hashed-password.age;
      };

      lriutzel-aws-beautyfromlight-key-id = {
        file = ./secrets/users/lriutzel/aws-beautyfromlight-key_id.age;
      };

      lriutzel-aws-beautyfromlight-access-key = {
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
