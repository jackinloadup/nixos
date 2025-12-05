{pkgs, lib, config, flake,  ...}: let
  inherit (lib) optionals mkIf;
in {
  # workaround for https://github.com/e-tho/ucodenix/issues/59
  disabledModules = [ "hardware/cpu/amd-microcode.nix" ];
  imports = [
    flake.inputs.ucodenix.nixosModules.default
    "${flake.inputs.nixpkgs-unstable}/nixos/modules/hardware/cpu/amd-microcode.nix"
  ];

  config = {
    boot = {
      initrd.kernelModules = ["kvm-amd" "amdgpu"];
      kernelModules = ["kvm-amd" "amdgpu" "amd_gpio" ];

      # ucodenix: Kernel microcode checksum verification is active. This may prevent microcode from loading. Consider disabling it by setting
      kernelParams = [ "microcode.amd_sha_check=off" ];

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

    #nixpkgs.config.rocmSupport = true;

    # maybe useful? opencl support using rocm
    #hardware.amdgpu.opencl.enable = true;

    # forgot what this was for
    #nixpkgs.config.packageOverrides = pkgs: {
    #  vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    #};


    # use amdvlk drivers instead mesa radv drivers
    # maybe mesa drivers are better??
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
        #pkgs.driversi686Linux.amdvlk # gone in 25.11, idk
      ];
    };

    # some of these could be placed into home-manager?
    # disabled because this is added onto servers which don't' need them
    environment.systemPackages = [
      #pkgs.ryzenadj # not in use
      #pkgs.zenstates # not in use
      pkgs.radeontop #  Top for amd cards. Could maybe be placed somewhere else? debug only if possible?
      #pkgs.radeon-profile # gui - need to figure out how to grant correct permissions
      pkgs.nvtopPackages.amd
    ];

    #nixpkgs.overlays = [
      # Math libraries for AMD CPUs
      # causes rebuilds, ran into a lot of failed python tests
      #(self: super:
      #  {
      #    blas = super.blas.override {
      #      blasProvider = self.amd-blis;
      #    };
      #
      #    lapack = super.lapack.override {
      #      lapackProvider = self.amd-libflame;
      #    };
      #  }
      #)
    #];

    services.ucodenix.enable = true;
  };
}

