{ nixosConfig
, ...
}:
{
  imports = [ ];

  config = {
    # Home manager will have the same stateVersion as system
    home.stateVersion = nixosConfig.system.stateVersion;

    programs.home-manager.enable = true;
  };
}
