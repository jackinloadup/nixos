{ lib, pkgs, config, inputs, ... }:

{
  config = {
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true; #TODO limit to authorized keys only
      permitRootLogin = "yes";
      passwordAuthentication = false;
      startWhenNeeded = true;
    };

    services.sshguard = {
      enable = true;
      detection_time = 3600;
    };
  };
}
