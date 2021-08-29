{ config, lib, pkgs, ... }:

{
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware = {
    # Enable amd microcode updates.
    cpu.amd.updateMicrocode = true;

    # Enable intel opengl hardware acceleration.
    opengl = {
      extraPackages = with pkgs; [
        rocm-opencl-icd # Enable opencl
      ];
    };
  };
}
