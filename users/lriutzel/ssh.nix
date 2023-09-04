{...}: {
  config = {
    programs.ssh = {
      compression = true;

      controlPersist = "30m";
      controlMaster = "auto";
      controlPath = "/run/user/%i/ssh-%r@%h:%p";

      #forwardX11 = false;
      forwardAgent = false; # don't forward the ssh agent (security risk)

      serverAliveCountMax = 3;
      serverAliveInterval = 30;

      #TCPKeepAlive = true;
      hashKnownHosts = false; # Privacy concern


      matchBlocks = {
        "all" = {
          user = "lriutzel";
          extraOptions = {
            preferredAuthentications = "publickey,keyboard-interactive,password";
          };
        };
        "*.compute.amazonaws.com" = {
          forwardAgent = false;
          extraOptions = {
            strictHostKeyChecking = "no";
            userKnownHostsFile = "/dev/null";
          };
        };
        "github github.com" = {
          hostname = "github.com";
          user = "git";
          forwardAgent = false;
          extraOptions = {
            preferredAuthentications = "publickey";
          };
        };
      };
    };
  };
}
