{ pkgs, ... }: let 
  flake = import ./flake.nix;
in {
  # ssh setup
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1pkTHUApo4oX3PLXnXcTLZ7xszEdeYJfBFEUyliYgD32INvsvQhl3ZmhZ1P5IMDmrMb/zd9dsMbtfY1fgy+unSMblb6RS7SxOt6vfifxNc1R7ylaa1HufgAhJHT+bSWNGPliA5Ds2XbdbPh3I6yRFT+V37QUz9EesDFaUC0JVEgqVOAUikSAGXhAeskTpQhD//32lEPwPM45iVS7Zix34LYrQ/RyVL9EKMRGLGFkJ3UgLsn6j8Wos7EM9YoW8s7lueShBcCFLqGus2Mjg71L14MWM1CCtaiFeBr04BtmhtvCjKJ505zfVLWLC8bg/URR6mIZABc1OqKRnm017tlJ3Q== lriutzel@gmail.com"];
    #hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  };
  boot.initrd.availableKernelModules = [ "igb" ];

  # Allow the user to login as root without password.
  users.extraUsers.root.initialHashedPassword = "";

  # show IP in login screen
  # https://github.com/NixOS/nixpkgs/issues/63322
  environment.etc."issue.d/ip.issue".text = "\\4\n";
  networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";

  #services.openssh.enable = true;
  virtualisation = {
    cores = 2;
    memorySize = 1024;
    graphics = true;
    qemu = {
      options = [ "-bios" "${pkgs.OVMF.fd}/FV/OVMF.fd" ];
      networkingOptions = [
        # We need to re-define our usermode network driver
        # since we are overriding the default value.
        "-net nic,netdev=user.1,model=virtio"
        # Than we can use qemu's hostfwd option to forward ports.
        "-netdev user,id=user.1,hostfwd=tcp::2222-:22"
      ];
    };
  };

  services.xserver.enable = true;

  services.openssh.enable = true;
}
