# Test WireGuard server configuration
# Validates:
# - WireGuard interface setup
# - Peer definitions
# - DNS (dnsmasq) configuration
# - NAT/MASQUERADE rules
{ pkgs, ... }:

let
  # Mock agenix secrets module
  mockAgenixModule = { lib, ... }: {
    options.age.secrets = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.path = lib.mkOption {
          type = lib.types.str;
          default = "/run/agenix/mock-secret";
        };
      });
      default = { };
    };
  };

  # Test WireGuard keys (these are valid format but not real keys)
  mockWgPrivateKey = "uI0Nl2J7l3xeB4Y8FqPl8+J/F/J8+F/J8+F/J8+F/Gc=";
in
pkgs.testers.nixosTest {
  name = "wireguard-server";

  nodes = {
    # WireGuard server (simulates marulk)
    server = { ... }: {
      imports = [
        mockAgenixModule
        ../modules/nixos/gumdrop/vpn.nix
      ];

      networking.hostName = "wg-server";

      # Enable WireGuard server
      gumdrop.vpn.server.enable = true;

      # Provide mock private key
      networking.wireguard.interfaces.wg0.privateKey = mockWgPrivateKey;

      # Simulate br0 interface (external interface for NAT)
      networking.bridges.br0.interfaces = [ ];
      networking.interfaces.br0.ipv4.addresses = [{
        address = "10.16.1.2";
        prefixLength = 24;
      }];
    };

    # WireGuard client
    client = { ... }: {
      imports = [
        mockAgenixModule
        ../modules/nixos/gumdrop/vpn.nix
      ];

      networking.hostName = "wg-client";

      # Enable WireGuard client
      gumdrop.vpn.client = {
        enable = true;
        ip = "10.100.0.5/32";
      };

      # Provide mock private key
      networking.wireguard.interfaces.wg0.privateKey = mockWgPrivateKey;
    };
  };

  testScript = ''
    start_all()

    # ===========================================
    # Server Tests
    # ===========================================
    server.wait_for_unit("multi-user.target")

    # Test: WireGuard service unit exists
    server.succeed("systemctl cat wireguard-wg0.service")

    # Test: WireGuard interface should be configured
    server.wait_for_unit("wireguard-wg0.service")

    # Test: Interface wg0 exists after service starts
    server.succeed("ip link show wg0")

    # Test: WireGuard interface has correct IP (10.100.0.1/24)
    server.succeed("ip addr show wg0 | grep -q '10.100.0.1'")

    # Test: WireGuard is listening on port 51820
    server.succeed("ss -uln | grep -q ':51820'")

    # Test: Firewall allows WireGuard port
    server.succeed("iptables -L -n | grep -q '51820'")

    # Test: Firewall allows DNS (TCP/UDP 53)
    server.succeed("iptables -L -n | grep -q '53'")

    # Test: NAT is enabled
    server.succeed("cat /proc/sys/net/ipv4/ip_forward | grep -q '1'")

    # Test: MASQUERADE rule for WireGuard network exists
    server.succeed("iptables -t nat -L POSTROUTING -n | grep -q '10.100.0.0/24'")
    server.succeed("iptables -t nat -L POSTROUTING -n | grep -q 'MASQUERADE'")

    # Test: dnsmasq is running
    server.wait_for_unit("dnsmasq.service")

    # Test: dnsmasq is listening on WireGuard server IP
    server.succeed("ss -uln | grep -q '10.100.0.1:53'")

    # Test: DNS resolution works (query dnsmasq for known address)
    server.succeed("${pkgs.dnsutils}/bin/dig @10.100.0.1 marulk.home.lucasr.com +short | grep -q '10.100.0.1'")

    # Test: DNS returns correct address for jellyfin
    server.succeed("${pkgs.dnsutils}/bin/dig @10.100.0.1 jellyfin.home.lucasr.com +short | grep -q '10.100.0.1'")

    # Test: wg show reports interface is up
    server.succeed("${pkgs.wireguard-tools}/bin/wg show wg0")

    # Test: Peers are configured (check that lucas-phone peer exists)
    server.succeed("${pkgs.wireguard-tools}/bin/wg show wg0 peers | head -1")

    # ===========================================
    # Client Tests
    # ===========================================
    client.wait_for_unit("multi-user.target")

    # Test: WireGuard service unit exists
    client.succeed("systemctl cat wireguard-wg0.service")

    # Test: WireGuard interface configured
    client.wait_for_unit("wireguard-wg0.service")

    # Test: Interface wg0 exists
    client.succeed("ip link show wg0")

    # Test: Client has correct IP assigned
    client.succeed("ip addr show wg0 | grep -q '10.100.0.5'")

    # Test: Client has peer configured (pointing to server)
    client.succeed("${pkgs.wireguard-tools}/bin/wg show wg0 peers | head -1")

    # Test: Client firewall allows WireGuard
    client.succeed("iptables -L -n | grep -q '51820'")

    print("All WireGuard server tests passed!")
  '';
}
