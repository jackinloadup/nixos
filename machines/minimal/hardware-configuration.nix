{...}: {
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/efi";
    fsType = "vfat";
    options = [
      "defaults"
      "x-gvfs-hide"
      "noatime"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    options = [
      "defaults"
      "x-gvfs-hide"
      "noatime"
      "discard"
    ];
  };
}
