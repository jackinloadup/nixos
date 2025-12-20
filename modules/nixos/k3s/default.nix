{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.k3s.enable {
    environment.systemPackages = [
      # conflicted with k3s, which provides a variation of the package
      #pkgs.kubectl
      # pkgs.kty # not used yet
      # pkgs.lens # not used and closed source
      # pkgs.seabird # native desktop app that simplifies working with Kubernetes
      # pkgs.k9s
      # pkgs.kdash
    ];

    # This is required so that pod can reach the API server (running on port 6443 by default)
    networking.firewall.allowedTCPPorts = [ 6443 ];

    #services.k3s = {
    #  serverAddr = "https://k3s.home.lucasr.com:6443";
    #};

    # network policies https://nixos.wiki/wiki/k3s
    systemd.services.k3s.path = [ pkgs.ipset ];
  };
}
