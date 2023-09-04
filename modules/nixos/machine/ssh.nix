{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkDefault;
in {
  # explore locking ssh capabilities by user
  # debug1: Remote: /etc/ssh/authorized_keys.d/lriutzel:1: key options: agent-forwarding port-forwarding pty user-rc x11-forwarding

  config = {
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = mkDefault true; #TODO limit to authorized keys only
      allowSFTP = mkDefault true; # maybe controls if scp works?
      startWhenNeeded = mkDefault true;

      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
        # disable insecure ciphers and macs
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
        KexAlgorithms = [
          "curve25519-sha256@libssh.org"
        ];
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512,hmac-sha2-256"
        ];
      };

      extraConfig = ''
        # don't allow system accounts to login
        # possibly change this to a new group like ssh_login
        AllowGroups users
        PermitEmptyPasswords no
      '';

      # ssh-keyscan HOST
      knownHosts = {
        "github.com" = {
          hostNames = [
            "github.com"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
      };
    };

    services.sshguard = {
      enable = mkDefault true;
      detection_time = 3600;
    };
  };
}
