# Julia's Lappy
# Manufacture Name | Lenovo
#     Product Line | Ideapad
#     Product Name | 100S-11BY
#       Model Name | 80R2
#    Serial Number | YD003X97
{ self, nixos-hardware, ... }: {
  imports = [
    ../../profiles/intel.nix
  ];

  # Lappy has an odd efi setup. Read about this flag
  boot.loader.grub.forcei686 = true;
}
