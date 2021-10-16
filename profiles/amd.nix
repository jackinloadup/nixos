{ config, lib, pkgs, ... }:

{
  #boot.kernelModules = [ "kvm-amd" ]; need to investigate

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware = {
    # Enable amd microcode updates.
    cpu.amd.updateMicrocode = true;

    # Enable intel opengl hardware acceleration.
    opengl = {
      extraPackages = with pkgs; [
        radeontop #  Top for amd cards. Could maybe be placed somewhere else? debug only if possible?
      ];
    };
  };
}
