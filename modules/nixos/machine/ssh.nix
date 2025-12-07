{ lib, ... }: let
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
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        X11Forwarding = false;

        # don't allow system accounts to login
        # possibly change this to a new group like ssh_login
        #
        # Added root to allow remote nix builders
        AllowGroups = [ "users" "root" ];

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
          "sntrup761x25519-sha512"
          "sntrup761x25519-sha512@openssh.com"
          "mlkem768x25519-sha256"
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
        ];
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512,hmac-sha2-256"
        ];
      };

      extraConfig = ''
        PermitEmptyPasswords no
      '';

      # ssh-keyscan HOST
      knownHosts = {
        "github.com" = {
          hostNames = [ "github.com" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
        #"nixos-install-iso" = {
        #  hostNames = [ "10.16.1.???"];
        #  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGgUJ/VnKHrTmGA+v6Ig49iObL9lKK5h9Uq1vu0Dxgk";
        #};
      };
    };

    services.sshguard = {
      enable = mkDefault true;
      detection_time = 3600;
      attack_threshold = 50; # 5 failed attempts. ~10 per;
      whitelist = [ "10.16.0.0/8" "10.100.0.0/24" ];
    };

    systemd.services.sshguard.serviceConfig = {
      TimeoutStopSec = "5s";
      KillMode = "mixed";
    };

    systemd.services.sshguard.before = [ "shutdown.target" ];
  };
}
