{ config, lib, pkgs, ... }:

{
  boot = {
    # used on newer thinkpads for tlp power saving.
    extraModulePackages = with config.boot.kernelPackages; [
      acpi_call
    ];

    # used on newer thinkpads for tlp power saving.
    kernelModules = [
      "acpi_call"
      "kvm-intel"
    ];
    initrd.kernelModules = [ "i915" ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    # Enable intel microcode updates.
    cpu.intel.updateMicrocode = true;

    # Enable intel opengl hardware acceleration.
    opengl = {
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver 
      ];
    };
  };
}
