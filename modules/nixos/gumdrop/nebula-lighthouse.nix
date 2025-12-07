{config, lib, ...}: let
  inherit (lib) mkIf;
  cfg = config.services.nebula.networks.gumdrop;
in mkIf cfg.enable {
  config = {
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.firewall.extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.16.50.0/24 -d 10.16.1.0/24 -j MASQUERADE
      iptables -I FORWARD 1 -s 10.16.50.0/24 -d 10.16.1.0/24 -j ACCEPT
      iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    '';

    services.nebula.networks.gumdrop.islighthouse = true;
  };
}
