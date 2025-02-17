{pkgs, lib, config,  ...}: let
  inherit (lib) optionals mkIf;
in {
  boot = {
    initrd.kernelModules = ["kvm-amd" "amdgpu"];
    kernelModules = ["kvm-amd" "amdgpu" "amd_gpio" ];
    #kernelParams = [
    #  #"nosgx" # remove "SGX disable by BIOS" message on boot
    #  #"intel_iommu=on"
    #] ++ optionals (!config.boot.initrd.verbose) [
    #  # may cause loss of backlight control
    #  # Should keep resolution on boot
    #  #"i915.fastboot=1"
    #];
    #extraModprobeConfig = "options snd-hda-intel enable_msi=1";
  };
  services.xserver.videoDrivers = ["amdgpu"];

  # forgot what this was for
  #nixpkgs.config.packageOverrides = pkgs: {
  #  vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  #};


  # use amdvlk drivers instead mesa radv drivers
  # maybe mesa dribers are better??
  ##hardware.amdgpu.amdvlk.enable = true;

  #environment.variables = {
  #  AMD_DEBUG = "nodcc";
  #};

  #hardware.opengl.driSupport32Bit = true;
  hardware.graphics = {
    # antiquated in 24.11
    #driSupport = true;
    #driSupport32Bit = true;

    extraPackages = [
      #pkgs.amdvlk # causing large black border around gnome apps
      #pkgs.rocm-opencl-icd
      #pkgs.rocm-opencl-runtime
      # https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/amd/default.nix
      #pkgs.rocmPackages.clr
    ];

    # For 32 bit applications
    extraPackages32 = [
      pkgs.driversi686Linux.amdvlk
    ];
  };


  # some of these could be placed into home-manager?
  environment.systemPackages = [
    pkgs.ryzenadj
    pkgs.zenstates
    pkgs.radeontop #  Top for amd cards. Could maybe be placed somewhere else? debug only if possible?
    pkgs.radeon-profile
    pkgs.nvtopPackages.amd
  ];
}

