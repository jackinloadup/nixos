{ lib, pkgs, config, inputs, ... }:

let
  inherit (lib) mkDefault;
in {
  # explore locking ssh capabilities by user
  # debug1: Remote: /etc/ssh/authorized_keys.d/lriutzel:1: key options: agent-forwarding port-forwarding pty user-rc x11-forwarding

  config = {
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = mkDefault true; #TODO limit to authorized keys only
      allowSFTP = mkDefault true; # maybe controls if scp works?
      permitRootLogin = "yes";
      passwordAuthentication = false;
      startWhenNeeded = mkDefault true;

      # disable insecure ciphers and macs
      ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
      kexAlgorithms = [
        "curve25519-sha256@libssh.org"
      ];
      macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-512,hmac-sha2-256"
      ];
      extraConfig = ''
        # don't allow system accounts to login
        # possibly change this to a new group like ssh_login
        AllowGroups users
        PermitEmptyPasswords no
      '';
    };

    services.sshguard = {
      enable = mkDefault true;
      detection_time = 3600;
    };
  };
}
