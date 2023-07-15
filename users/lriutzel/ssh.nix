{...}: {
  config = {
    programs.ssh = {
      controlPersist = "4h";
      controlMaster = "auto";
      controlPath = "/run/user/%i/ssh-%r@%h:%p";

      #forwardX11 = false;
      forwardAgent = false; # don't forward the ssh agent (security risk)

      serverAliveCountMax = 3;
      serverAliveInterval = 5;

      #TCPKeepAlive = true;
      hashKnownHosts = true;


      matchBlocks = {
        "all" = {
          user = "lriutzel";

        };
      };
    };
  };
}
