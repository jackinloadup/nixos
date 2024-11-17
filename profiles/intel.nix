{pkgs, lib, config,  ...}: let
  inherit (lib) optionals mkIf;
in {
  boot = {
    initrd.kernelModules = ["kvm-intel"];
    kernelModules = ["kvm-intel"];
    kernelParams = [
      "nosgx" # remove "SGX disable by BIOS" message on boot
      #"intel_iommu=on"
    ] ++ optionals (!config.boot.initrd.verbose) [
      # may cause loss of backlight control
      # Should keep resolution on boot
      "i915.fastboot=1"
    ];
    extraModprobeConfig = "options snd-hda-intel enable_msi=1";
  };
  services.xserver.videoDrivers = ["intel"];

  # forgot what this was for
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  environment.systemPackages = [
    pkgs.intel-gpu-tools # intel_gpu_top and others
    pkgs.nvtopPackages.intel
  ];
}
