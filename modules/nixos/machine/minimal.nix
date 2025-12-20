{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.machine;
in
{
  imports = [
    # causing infinite recursion
    #(inputs.nixpkgs + "nixos/modules/profiles/minimal.nix")
  ];

  options.machine.minimal = mkEnableOption "Disable stuff not needed on minimal systems";

  config = mkIf cfg.minimal {
    # Unsure if the following takes up space
    #boot.enableContainers = mkDefault false;
    #fonts.fontconfig.enable = mkDefault false;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.man.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;



    # Remove unnessisary vpn plugins mostly
    # I don't think this is having the impact I expect
    # Still see openvpn and other things
    networking.networkmanager.plugins = mkDefault [ ];

    # This may be undesirable if Nix commands are not going to be run on the
    # built system since it adds nixpkgs to the system closure. For such
    # closure-size-constrained non-interactive systems, this setting should
    # be disabled.
    nixpkgs.flake.setNixPath = mkDefault false;
    nixpkgs.flake.setFlakeRegistry = mkDefault false;

    programs.bash.completion.enable = mkDefault false;
    programs.command-not-found.enable = mkDefault false;

    #environment.noXlibs = mkDefault true;

    ## Remove polkit. It depends on spidermonkey !
    security.polkit.enable = mkDefault false;

    #sound.enable = mkDefault false;


  };
}
