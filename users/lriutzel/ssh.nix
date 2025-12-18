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
      enableDefaultConfig = false;

      extraConfig = ''
        ConnectTimeout 5
      '';
        #PermitLocalCommand yes


      matchBlocks = {
        "*" = {
          # add used keys to agent
          addKeysToAgent = "yes";

          user = "lriutzel";

          compression = true;

          controlPersist = "30m";
          controlMaster = "auto";
          controlPath = "/run/user/%i/ssh-%r@%h:%p";

          serverAliveCountMax = 3;
          serverAliveInterval = 30;

          #TCPKeepAlive = true;
          hashKnownHosts = false; # Privacy concern, but eh
          userKnownHostsFile = "~/.ssh/known_hosts";

          forwardAgent = false; # don't forward the ssh agent (security risk)

          extraOptions = {
            PreferredAuthentications = "publickey,keyboard-interactive,password";
            #localCommand = "printf '\033]4;4;#004080;12;#0040ff\007'";
          };

          setEnv = {
            # resolve issues when using an term like kitty
            TERM = "xterm-256color";
          };
        };
        "*.compute.amazonaws.com" = {
          forwardAgent = false;
          extraOptions = {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
          };
        };
        "dtcc github" = {
          match = ''Host github.com exec "pwd | grep ~/Projects/obsidian-systems/dtcc"'';
          forwardAgent = false;
          user = "git";
          hostname = "github.com";
          identityFile = "~/.ssh/keys/devx";
          extraOptions = {
            ControlPath = "/run/user/%i/ssh-devx";
            PreferredAuthentications = "publickey";
            IdentitiesOnly = "yes";
          };
        };
        "github github.com" = {
          match = ''Host github.com !exec "pwd | grep ~/Projects/obsidian-systems/dtcc"'';
          hostname = "github.com";
          user = "git";
          forwardAgent = false;
          extraOptions = {
            PreferredAuthentications = "publickey";
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
