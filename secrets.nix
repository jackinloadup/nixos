let
  selfLib = import ./lib/secrets.nix {};
  inherit (selfLib) machines hostHasService smachines shostHasService;
  inherit (builtins) filter readFile;
  lib = (import <nixpkgs> { }).pkgs.lib;
  inherit (lib) mkMerge mergeAttrsList;

  #orange = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPxPFMNGK0tw467usZYAA1mjgB2owDFBQT939dzOlBWyAAAABHNzaDo= orange";
  #black = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINmfKdhabJag/k0w78kqBG1PL8w+WMv7xWp4VbkdhtINAAAABHNzaDo= black";
  lriutzel_ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO/wQSQHq1Wmzbwg8uJM4vK/exUWmsT49kmkPdtJU0v lriutzel@gmail.com";
  lriutzel = [ lriutzel_ed25519 ];
  users = lriutzel;

  # public ssh key
  machineSshKey = (host: lib.readFile ./machines/${host}/sshd/public_key) ;
  sshKeyMap = map machineSshKey;
  machinesWithHostKeys = filter (host: hostHasService host "sshd") machines;
  machineKeys = sshKeyMap machinesWithHostKeys;

  machinesWithBootHostKeys = filter (host: hostHasService host "init-sshd") machines;
  machineBootKeys = map (host: readFile ./machines/${host}/init-sshd/public_key) machinesWithBootHostKeys;
  all = users ++ machineKeys;
  allBoot = users ++ machineBootKeys;

  servers = users ++ (sshKeyMap ["marulk" "reg"]);

  lucasDevHosts = lriutzel ++ (sshKeyMap ["reg" "riko"]);

  mkWgHost = (host: {
    "secrets/machines/${host}/wg-vpn/private.age".publicKeys = users ++ (sshKeyMap [host]);
    "secrets/machines/${host}/wg-vpn/public.age".publicKeys = users ++ (sshKeyMap [host]);
  });
  wgHosts = filter (host: shostHasService host "wg-vpn") smachines;
  wgHostsConfig = mergeAttrsList (map mkWgHost wgHosts);

  mkTorHost = (host: {
    "secrets/machines/${host}/tor-service/hostname.age".publicKeys = users ++ (sshKeyMap [host]);
    "secrets/machines/${host}/tor-service/hs_ed25519_public_key.age".publicKeys = all;
    "secrets/machines/${host}/tor-service/hs_ed25519_secret_key.age".publicKeys = users ++ (sshKeyMap [host]);
  });
  torHosts = filter (host: shostHasService host "tor-service") smachines;
  torHostsConfig = mergeAttrsList (map mkTorHost torHosts);

  mkSshdHost = (host: {
    "secrets/machines/${host}/sshd/private_key.age".publicKeys = users ++ (sshKeyMap [host]);
  });
  sshdHosts = filter (host: shostHasService host "sshd") smachines;
  sshdHostsConfig = mergeAttrsList (map mkSshdHost sshdHosts);

  mkInitSshdHost = (host: {
    "secrets/machines/${host}/init-sshd/private_key.age".publicKeys = users ++ (sshKeyMap [host]);
  });
  initSshdHosts = filter (host: shostHasService host "init-sshd") smachines;
  initSshdHostsConfig = mergeAttrsList (map mkInitSshdHost initSshdHosts);
in
{
  "secrets/services/namecheap/api-key.age".publicKeys = servers;
  "secrets/services/namecheap/api-user.age".publicKeys = servers;

  #"secrets/services/ssh_nextcloud_ed25519_key.age".publicKeys = all;
  #"secrets/services/ssh_nextcloud_ed25519_key.pub.age".publicKeys = all;
#  "secrets/services/boot.age".publicKeys = allBoot;

  "secrets/services/nextcloud/db-pass.age".publicKeys = servers;

  "secrets/services/nix/signing-key.age".publicKeys = servers;
  "secrets/services/nix/signing-key.pub.age".publicKeys = servers;

  "secrets/services/immich/secretsFile".publicKeys = servers;

  "secrets/commonPass.age".publicKeys = all;
  "secrets/system/wireless-networking.age".publicKeys = all;

  # service users
  "secrets/users/serviceftp/hashed-password.age".publicKeys = all;

  "secrets/users/lriutzel/aws-beautyfromlight-key_id.age".publicKeys = lucasDevHosts;
  "secrets/users/lriutzel/aws-beautyfromlight-access_key.age".publicKeys = lucasDevHosts;

  "secrets/users/lriutzel/hashed-password.age".publicKeys = all;
  "secrets/users/criutzel/hashed-password.age".publicKeys = all;
  "secrets/users/briutzel/hashed-password.age".publicKeys = all;
}
// wgHostsConfig
// torHostsConfig
// sshdHostsConfig
// initSshdHostsConfig
