{ ... }: {
  config = {
    services.syncthing.settings.devices.reg = {
      addresses = [
        "tcp4://reg.home.lucasr.com"
        "tcp4://10.16.1.11:51820"
        "dynamic"
      ];
      id = "7CFNTQM-IMTJBHJ-3UWRDIU-ZGQJFR6-VCXZ3NB-XUH3KZO-N52ITXR-LAIYUAU";
    };
  };
}
