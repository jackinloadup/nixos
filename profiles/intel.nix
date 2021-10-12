{ config, lib, pkgs, ... }:

{
  boot = {
    kernelModules = [
      "kvm-intel"
    ];
  };

  # forgot what this was for
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  environment.systemPackages = with pkgs; [
    intel-gpu-tools # intel_gpu_top and others
  ];
}
