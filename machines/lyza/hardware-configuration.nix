{ lib, ... }:

{
  imports = [
    ../../profiles/intel.nix
    ../../profiles/disk-workstation.nix
  ];

  config = {
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.loader.efi.canTouchEfiVariables = true;
    boot.extraModprobeConfig = "options snd-hda-intel enable_msi=1";

    #-----------------------------------
    # initrd remote decrypt root
    #-----------------------------------
    # Network card drivers. Check `lshw` if unsure.
    boot.initrd.kernelModules = [
      "ath9k" # wireless
      "r8169" # wired
      "usbnet"
    ];
    # It may be necessary to wait a bit for devices to be initialized.
    # See https://github.com/NixOS/nixpkgs/issues/98741
    boot.initrd.preLVMCommands = lib.mkBefore 400 "sleep 1";
    # Your post-boot network configuration is taken
    # into account. It should contain:
    networking.useDHCP = false;
    networking.interfaces.wlan0.useDHCP = true;
    networking.interfaces.enp1s0.useDHCP = true;
    boot.initrd = {
      network = {
        enable = true;
        ssh = {
          enable = true;
          # Defaults to 22.
          #port = 222;
        };
      };
      # Set the shell profile to meet SSH connections with a decryption
      # prompt that writes to /tmp/continue if successful.
      #network.postCommands = let
      #  # I use a LUKS 2 label. Replace this with your disk device's path.
      #  disk = "/dev/disk/by-label/crypt";
      #in ''
      #  echo 'cryptsetup open ${disk} root --type luks && echo > /tmp/continue' >> /root/.profile
      #  echo 'starting sshd...'
      #'';
      # Block the boot process until /tmp/continue is written to
      postDeviceCommands = ''
        echo 'waiting for root device to be opened...'
        mkfifo /tmp/continue
        cat /tmp/continue
      '';
    };
    #-----------------------------------
  };
}
