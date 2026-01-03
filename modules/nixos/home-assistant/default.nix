{ lib, config, pkgs, inputs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkForce mkOption types;
  cfg = config.machine.home-assistant;
  nixvirt = inputs.NixVirt;

  # Bridged network - forwards to existing br0 bridge
  bridgedNetwork = {
    name = "bridged-network";
    uuid = "c4acfd00-4597-41c7-a48e-e2302234fa89";
    forward = { mode = "bridge"; };
    bridge = { name = "br0"; };
  };

  # Home Assistant VM domain (Q35 chipset)
  hassDomain = {
    type = "kvm";
    name = "hass";
    uuid = "269c111e-e62e-4b82-80b5-5abd1aeaf877";

    memory = { count = cfg.memory; unit = "MiB"; };
    vcpu = { count = cfg.vcpus; };

    os = {
      type = "hvm";
      arch = "x86_64";
      machine = "q35";
      loader = {
        readonly = true;
        type = "pflash";
        path = "${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd";
      };
      nvram = {
        template = "${pkgs.OVMFFull.fd}/FV/OVMF_VARS.fd";
        path = "/var/lib/libvirt/qemu/nvram/hass_VARS.fd";
      };
      boot = [{ dev = "hd"; }];
    };

    features = {
      acpi = { };
      apic = { };
    };

    cpu = { mode = "host-passthrough"; };

    clock = {
      offset = "utc";
      timer = [
        { name = "rtc"; tickpolicy = "catchup"; }
        { name = "pit"; tickpolicy = "delay"; }
        { name = "hpet"; present = false; }
      ];
    };

    devices = {
      emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";

      # Main disk (SATA for HAOS compatibility)
      disk = [{
        type = "file";
        device = "disk";
        driver = { name = "qemu"; type = "qcow2"; };
        source = { file = cfg.diskPath; };
        target = { dev = "sda"; bus = "sata"; };
      }];

      # Bridge network interface
      interface = {
        type = "network";
        source = { network = "bridged-network"; };
        model = { type = "e1000"; };
        mac = { address = "52:54:00:c0:82:f2"; };
      };

      # USB controller (XHCI for Q35)
      controller = [{
        type = "usb";
        index = 0;
        model = "qemu-xhci";
      }];

      # Zigbee USB passthrough (Silicon Labs CP210x)
      hostdev = [{
        mode = "subsystem";
        type = "usb";
        managed = true;
        source = {
          vendor = { id = 4292; }; # 0x10c4
          product = { id = 60000; }; # 0xea60
        };
      }];

      # SPICE graphics
      graphics = {
        type = "spice";
        autoport = true;
        listen = { type = "address"; address = "0.0.0.0"; };
      };

      video = {
        model = { type = "qxl"; ram = 65536; vram = 65536; };
      };

      channel = [{
        type = "spicevmc";
        target = { type = "virtio"; name = "com.redhat.spice.0"; };
      }];

      serial = [{ type = "pty"; }];
      console = [{ type = "pty"; target = { type = "serial"; }; }];

      memballoon = { model = "virtio"; };
    };
  };
in
{
  options.machine.home-assistant = {
    enable = mkEnableOption "Home Assistant VM";

    diskPath = mkOption {
      type = types.path;
      default = "/var/lib/libvirt/images/haos.qcow2";
      description = "Path to the HAOS qcow2 disk image";
    };

    memory = mkOption {
      type = types.int;
      default = 1550;
      description = "Memory in MiB";
    };

    vcpus = mkOption {
      type = types.int;
      default = 2;
      description = "Number of virtual CPUs";
    };
  };

  config = mkIf cfg.enable {
    users.users.lriutzel.extraGroups = [ "dialout" ];

    networking.firewall.allowedTCPPorts = [ 1883 5900 8123 4357 ];

    services.mosquitto = {
      enable = true;
      settings.max_keepalive = 300;
      listeners = [{
        port = 1883;
        users.mosquitto = {
          acl = [ "readwrite #" ];
          password = "mosquitto";
        };
      }];
    };

    systemd.services.mosquitto.requires = [ "network-online.target" ];

    # Standard libvirtd
    virtualisation.libvirtd.enable = mkForce true;
    virtualisation.libvirtd.onShutdown = "shutdown";

    # NixVirt declarative VM management
    virtualisation.libvirt = {
      enable = true;
      connections."qemu:///system" = {
        networks = [{
          definition = nixvirt.lib.network.writeXML bridgedNetwork;
          active = true;
        }];
        domains = [{
          definition = nixvirt.lib.domain.writeXML hassDomain;
          active = true;
        }];
      };
    };
  };
}
