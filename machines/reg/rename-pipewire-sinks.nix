{ self, inputs, pkgs, lib, ... }:

{
  services.pipewire = {
    media-session.config.alsa-monitor.rules = [
      {
        matches = [{ "device.vendor.id" = "4130"; }];
        actions = {
          "update-props" = {
            "device.description" =  "Motherboard";
            "device.product.name" = "Motherboard";
          };
        };
      }
      {
        matches = [{ "device.vendor.id" = "4098"; }];
        actions = {
          "update-props" = {
            "device.description" =  "GPU";
            "device.product.name" = "GPU";
          };
        };
      }
    ];
  };
}
