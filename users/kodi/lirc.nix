{ self
, inputs
, pkgs
, lib
, config
, ...
}: {
  imports = [
  ];

  config = {
    services.lirc = {
      enable = true;
    };
  };
}
