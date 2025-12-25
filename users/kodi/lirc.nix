{ ...
}: {
  imports = [
  ];

  config = {
    services.lirc = {
      enable = true;
    };
  };
}
