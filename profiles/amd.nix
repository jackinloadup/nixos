{ config, lib, pkgs, ... }:

{
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
  };
  #boot.kernelModules = [ "kvm-amd" ]; need to investigate

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware = {
    # Enable amd microcode updates.
    cpu.amd.updateMicrocode = true;

    # Enable intel opengl hardware acceleration.
    opengl = {
      extraPackages = with pkgs; [
        rocm-opencl-icd # Enable opencl
        rocm-opencl-runtime
      ];
    };
  };
}
