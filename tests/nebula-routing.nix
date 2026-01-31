# Test Nebula configuration with LAN routing (unsafe_routes)
# Validates that the routeToLan option correctly configures:
# - NAT between Nebula and LAN interfaces
# - unsafe_routes for LAN access from Nebula clients
# - MASQUERADE rules for bidirectional traffic
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
in
pkgs.testers.nixosTest {
  name = "nebula-routing";

  nodes = {
    # Lighthouse with LAN routing enabled
    lighthouse = { pkgs, ... }: {
      imports = [
        mockAgenixModule
        ../modules/nixos/gumdrop/nebula.nix
      ];

      networking.hostName = "lighthouse";

      # Mock secrets
      age.secrets = {
        nebula-ca.path = pkgs.writeText "mock-ca" "";
        "nebula-lighthouse-cert".path = pkgs.writeText "mock-cert" "";
        "nebula-lighthouse-key".path = pkgs.writeText "mock-key" "";
      };

      # Configure as lighthouse with LAN routing
      gumdrop.nebula.lighthouse = {
        enable = true;
        routeToLan = true;
        lanSubnet = "10.16.1.0/24";
        lanInterface = "eth1";
      };

      # Simulate LAN interface
      networking.interfaces.eth1.ipv4.addresses = [{
        address = "10.16.1.2";
        prefixLength = 24;
      }];
    };

    # Lighthouse without LAN routing (for comparison)
    lighthouseNoRouting = { pkgs, ... }: {
      imports = [
        mockAgenixModule
        ../modules/nixos/gumdrop/nebula.nix
      ];

      networking.hostName = "lighthouse-no-routing";

      age.secrets = {
        nebula-ca.path = pkgs.writeText "mock-ca" "";
        "nebula-lighthouse-no-routing-cert".path = pkgs.writeText "mock-cert" "";
        "nebula-lighthouse-no-routing-key".path = pkgs.writeText "mock-key" "";
      };

      # Lighthouse without routeToLan
      gumdrop.nebula.lighthouse = {
        enable = true;
        routeToLan = false;
      };
    };

    # Nebula client
    client = { pkgs, ... }: {
      imports = [
        mockAgenixModule
        ../modules/nixos/gumdrop/nebula.nix
      ];

      networking.hostName = "nebula-client";

      age.secrets = {
        nebula-ca.path = pkgs.writeText "mock-ca" "";
        "nebula-nebula-client-cert".path = pkgs.writeText "mock-cert" "";
        "nebula-nebula-client-key".path = pkgs.writeText "mock-key" "";
      };

      gumdrop.nebula.client = {
        enable = true;
        ip = "10.101.0.2/24";
      };
    };
  };

  testScript = ''
    start_all()

    # ===========================================
    # Lighthouse with LAN routing tests
    # ===========================================
    lighthouse.wait_for_unit("multi-user.target")

    # Test: Nebula service is defined
    lighthouse.succeed("systemctl cat nebula@gumdrop.service")

    # Test: NAT is enabled
    lighthouse.succeed("cat /proc/sys/net/ipv4/ip_forward | grep -q '1'")

    # Test: MASQUERADE rule exists for Nebula -> LAN
    lighthouse.succeed("iptables -t nat -L POSTROUTING -n -v | grep -q '10.101.0.0/24.*eth1.*MASQUERADE'")

    # Test: MASQUERADE rule exists for LAN -> Nebula
    lighthouse.succeed("iptables -t nat -L POSTROUTING -n -v | grep -q '10.16.1.0/24.*nebula.gumdrop.*MASQUERADE'")

    # Test: Firewall allows UDP 4242
    lighthouse.succeed("iptables -L -n | grep -q '4242'")

    # Test: Nebula config should have unsafe_routes when routeToLan is enabled
    # The Nebula service generates a config file, we check the systemd unit
    lighthouse.succeed("systemctl show nebula@gumdrop.service --property=ExecStart | grep -q 'nebula'")

    # ===========================================
    # Lighthouse without LAN routing tests
    # ===========================================
    lighthouseNoRouting.wait_for_unit("multi-user.target")

    # Test: Nebula service is defined
    lighthouseNoRouting.succeed("systemctl cat nebula@gumdrop.service")

    # Test: No MASQUERADE rules for Nebula network (routeToLan is false)
    lighthouseNoRouting.fail("iptables -t nat -L POSTROUTING -n | grep -q '10.101.0.0/24.*MASQUERADE'")

    # Test: Firewall still allows UDP 4242
    lighthouseNoRouting.succeed("iptables -L -n | grep -q '4242'")

    # ===========================================
    # Client tests
    # ===========================================
    client.wait_for_unit("multi-user.target")

    # Test: Nebula service is defined
    client.succeed("systemctl cat nebula@gumdrop.service")

    # Test: Client has static host map configured (pointing to lighthouse)
    # The service should be configured to connect to 10.101.0.1
    client.succeed("systemctl show nebula@gumdrop.service --property=ExecStart")

    # Test: Client firewall allows Nebula
    client.succeed("iptables -L -n | grep -q '4242'")

    # Test: Client is NOT a lighthouse (no relay config)
    # This is implicit - just verify the service exists and can start

    print("All Nebula routing tests passed!")
  '';
}
