{...}: {
  config = {
    networking.firewall.allowedTCPPorts = [53];
    networking.firewall.allowedUDPPorts = [53];
    networking.interfaces.br0.ipv4.addresses = [{
      address = "10.16.1.2";
      prefixLength = 8;
    }];

    services.adguardhome = {
      enable = true;
      # opens port
      openFirewall = true;
      extraArgs = ["--no-etc-hosts"];
      port = 80; # Web gui
      host = "10.16.1.2";
    };

    # Ensures that adguardhome doesn't stop until libvirtd has
    # This is simply to keep DNS running as long as possible if running on
    # a machine also running libvirtd.
    systemd.services.libvirtd.after = ["adguardhome.service"];
  };
}
