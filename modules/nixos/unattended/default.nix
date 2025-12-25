{ lib
, config
, ...
}:
let
  inherit (lib) mkIf mkForce mkEnableOption;
in
{
  options.boot.unattended = mkEnableOption "Optimise for an unattended machine";

  #imports = mkIf config.boot.unattended [
  #  # unattended != headless, but it's a good start
  #  # Define unattended as "no user interaction required"
  #  # what I really mean is machine is unmanaged and should correct itself if
  #  # there is a failure. 
  #  # (inputs.nixpkgs + "nixos/modules/profiles/headless.nix")
  #];

  config = mkIf config.boot.unattended {
    # some of these values are also set in headless.
    machine.kernel = {
      rebootAfterPanic = mkForce 10;
      panicOnOOM = mkForce true;
      panicOnHungTaskTimeout = mkForce 1;
    };
  };
}
