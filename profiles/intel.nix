{ pkgs, ... }:

{
  boot = {
    initrd.kernelModules = [ "kvm-intel" ];
    kernelModules = [ "kvm-intel" ];
    extraModprobeConfig = "options snd-hda-intel enable_msi=1";
  };
  services.xserver.videoDrivers = [ "intel" ];

  # forgot what this was for
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  environment.systemPackages = with pkgs; [
    intel-gpu-tools # intel_gpu_top and others
  ];
}
