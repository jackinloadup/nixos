{...}: {
  # tool to sanity check a remote machine
  # - check how out of sync the clock is
  #   - maybe ssh already does this?
  config = {
    programs.ssh = {
      compression = true;

      controlPersist = "30m";
      controlMaster = "auto";
      controlPath = "/run/user/%i/ssh-%r@%h:%p";

      #forwardX11 = false;
      forwardAgent = true; # don't forward the ssh agent (security risk)

      serverAliveCountMax = 3;
      serverAliveInterval = 30;

      #TCPKeepAlive = true;
      hashKnownHosts = false; # Privacy concern
      #extraConfig = ''
      #  PermitLocalCommand yes
      #'';


      matchBlocks = {
        "all" = {
          user = "lriutzel";
          extraOptions = {
            preferredAuthentications = "publickey,keyboard-interactive,password";
            #localCommand = "printf '\033]4;4;#004080;12;#0040ff\007'";
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
        "truenas" = {
          hostname = "truenas.home.lucasr.com";
          # Setup a dynamic port forward allow kubectl to connect to the cluster
          dynamicForwards = [{ port = 4444; }];
        };
      };
    };
  };
}
