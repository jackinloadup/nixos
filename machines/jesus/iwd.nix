{pkgs, ...}: {
  config = {
    # Playing with iwd
    environment.systemPackages = [pkgs.iwgtk];
    networking.networkmanager.wifi.backend = "iwd";
    networking.wireless.iwd.enable = true;
    networking.wireless.iwd.settings = {
      General = {
        AddressRandomization = "network";
        AddressRandomizationRange = "full";
        DisableANQP = false; # Hotspot 2.0 explore turning on
      };
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Settings = {
        AutoConnect = true;
        AlwaysRandomizeAddress = true;
      };
      Scan = {
        InitialPeriodicScanInterval = 1;
        MaximumPeriodicScanInterval = 60;
      };
    };
  };
}
