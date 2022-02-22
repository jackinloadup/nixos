{ pkgs, ... }: let 
  flake = import ./flake.nix;
in {
  virtualisation.qemu.options = [ "-bios" "${pkgs.OVMF.fd}/FV/OVMF.fd" ];
  #services.openssh.enable = true;
  virtualisation = {
    cores = 2;
    memorySize = 1024;
  };
  #services.xserver.enable = true;
  virtualisation.graphics = true;
} // flake.outputs.nixosConfigurations.nat
