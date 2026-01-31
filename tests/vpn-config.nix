# Test that VPN modules (Nebula + WireGuard) evaluate correctly
# and generate expected systemd services and firewall rules
{ pkgs, ... }:

let
  # Mock agenix secrets module - provides fake paths for testing
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

  # Generate mock WireGuard keys for testing
  mockWgPrivateKey = "uI0Nl2J7l3xeB4Y8FqPl8+J/F/J8+F/J8+F/J8+F/Gc=";
in
pkgs.testers.nixosTest {
  name = "vpn-config-validation";

  nodes = {
    # Server node - simulates marulk (lighthouse + WireGuard server)
    server = { pkgs, ... }: {
      imports = [
        mockAgenixModule
        ../modules/nixos/gumdrop/nebula.nix
        ../modules/nixos/gumdrop/vpn.nix
      ];

      networking.hostName = "test-server";

      # Mock secrets for Nebula
      age.secrets = {
        nebula-ca.path = pkgs.writeText "mock-ca" "";
        "nebula-test-server-cert".path = pkgs.writeText "mock-cert" "";
        "nebula-test-server-key".path = pkgs.writeText "mock-key" "";
      };

      # Enable Nebula lighthouse with LAN routing
      gumdrop.nebula.lighthouse = {
        enable = true;
        routeToLan = true;
        lanSubnet = "10.16.1.0/24";
        lanInterface = "eth1";
      };

      # Enable WireGuard server
      gumdrop.vpn.server.enable = true;

      # Mock WireGuard private key
      networking.wireguard.interfaces.wg0.privateKey = mockWgPrivateKey;

      # Create a mock LAN interface for testing
      networking.interfaces.eth1.ipv4.addresses = [{
        address = "10.16.1.2";
        prefixLength = 24;
      }];
    };

    # Client node - simulates a Nebula client
    client = { pkgs, ... }: {
      imports = [
        mockAgenixModule
        ../modules/nixos/gumdrop/nebula.nix
        ../modules/nixos/gumdrop/vpn.nix
      ];

      networking.hostName = "test-client";

      # Mock secrets for Nebula
      age.secrets = {
        nebula-ca.path = pkgs.writeText "mock-ca" "";
        "nebula-test-client-cert".path = pkgs.writeText "mock-cert" "";
        "nebula-test-client-key".path = pkgs.writeText "mock-key" "";
      };

      # Enable Nebula client
      gumdrop.nebula.client = {
        enable = true;
        ip = "10.101.0.2/24";
      };

      # Enable WireGuard client
      gumdrop.vpn.client = {
        enable = true;
        ip = "10.100.0.2/32";
      };

      # Mock WireGuard private key
      networking.wireguard.interfaces.wg0.privateKey = mockWgPrivateKey;
    };
  };

  testScript = ''
    start_all()

    # ===========================================
    # Server Tests
    # ===========================================
    server.wait_for_unit("multi-user.target")

    # Test: Nebula service unit exists
    server.succeed("systemctl cat nebula@gumdrop.service")

    # Test: WireGuard service unit exists
    server.succeed("systemctl cat wireguard-wg0.service")

    # Test: Firewall allows Nebula port (UDP 4242)
    server.succeed("iptables -L INPUT -n | grep -q '4242' || iptables -L -n | grep -q '4242'")

    # Test: Firewall allows WireGuard port (UDP 51820)
    server.succeed("iptables -L INPUT -n | grep -q '51820' || iptables -L -n | grep -q '51820'")

    # Test: NAT MASQUERADE rules exist for Nebula
    server.succeed("iptables -t nat -L POSTROUTING -n | grep -q 'MASQUERADE'")

    # Test: NAT MASQUERADE rule for Nebula network -> LAN
    server.succeed("iptables -t nat -L POSTROUTING -n | grep -q '10.101.0.0/24'")

    # Test: NAT MASQUERADE rule for WireGuard network
    server.succeed("iptables -t nat -L POSTROUTING -n | grep -q '10.100.0.0/24'")

    # Test: dnsmasq service is running (for WireGuard DNS)
    server.wait_for_unit("dnsmasq.service")

    # Test: dnsmasq is listening on WireGuard interface IP
    server.succeed("ss -uln | grep -q '10.100.0.1:53'")

    # ===========================================
    # Client Tests
    # ===========================================
    client.wait_for_unit("multi-user.target")

    # Test: Nebula service unit exists on client
    client.succeed("systemctl cat nebula@gumdrop.service")

    # Test: WireGuard service unit exists on client
    client.succeed("systemctl cat wireguard-wg0.service")

    # Test: Client firewall allows Nebula port
    client.succeed("iptables -L INPUT -n | grep -q '4242' || iptables -L -n | grep -q '4242'")

    print("All VPN configuration tests passed!")
  '';
}
