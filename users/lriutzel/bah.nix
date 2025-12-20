{ lib
, pkgs
, config
, ...
}: {
  imports = [
  ];

  config = {
    home.packages = [
      #pkgs.teams
      pkgs.teams-for-linux
    ];
  };
}
