{ pkgs
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
