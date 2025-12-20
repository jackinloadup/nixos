{ pkgs
, ...
}: {
  config = {
    services.trezord.enable = true;

    home-manager.sharedModules = [
      {
        home.packages = [
          pkgs.trezorctl
          pkgs.trezor_agent
          #pkgs.trezor-suite # wasn't building
          #pkgs.exodus # Cryptowallet
          #pkgs.electron-cash # BCH walle
        ];
      }
    ];


  };
}
