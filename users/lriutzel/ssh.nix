{...}: {
  # tool to sanity check a remote machine
  # - check how out of sync the clock is
  #   - maybe ssh already does this?
  config = {
    # What is sslh?
    #
    # sslh accepts connections in HTTP, HTTPS, SSH, OpenVPN, tinc, XMPP, or any
    # other protocol that can be tested using a regular expression, on the same
    # port. This makes it possible to connect to any of these servers on port
    # 443 while still serving HTTPS on that port.
    #services.sslh.enable = ?;

    programs.ssh = {
      # add used keys to agent
      addKeysToAgent = "yes";

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
      extraConfig = ''
        ConnectTimeout 5
      '';
        #PermitLocalCommand yes


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
