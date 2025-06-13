{
  lib,
  pkgs,
  config,
  flake,
  ...
}:
# If extraOpts can be expressed in home-manager that
# would be more ideal or at least an alterate if using
# nix seporate from nixos
let
  inherit (lib) mkIf mkEnableOption optionals;
in {
  imports = [
    flake.inputs.impermanence.nixosModules.impermanence
  ];

  options.machine.impermanence = mkEnableOption "Enable impermanence";

  config = mkIf config.machine.impermanence {
    programs.fuse.userAllowOther = true;

    environment.persistence = {
      "/persist" = {
        hideMounts = true;
        directories =
          [
            # The /var/lib/nixos directory contains the uid and gid map for
            # entities without a static id. Not persisting them means your user
            # and group ids could change between reboots
            # https://github.com/nix-community/impermanence/pull/114
            "/var/lib/nixos"

            "/var/lib/systemd/timers"
            #"/var/log"
          ]
          ++ optionals config.networking.networkmanager.enable [
            "/etc/NetworkManager/system-connections"
          ]
          ++ optionals config.systemd.coredump.enable [
            "/var/lib/systemd/coredump"
          ]
          ++ optionals config.hardware.bluetooth.enable [
            "/var/lib/bluetooth"
          ]
          ++ optionals config.virtualisation.docker.enable [
            "/var/lib/docker"
            config.services.dockerRegistry.storagePath
          ]
          ++ optionals config.virtualisation.libvirtd.enable [
            "/var/lib/libvirt"
          ]
          ++ optionals config.services.blueman.enable [
            "/var/lib/blueman"
          ]
          ++ optionals config.services.open-webui.enable  [
            "/var/lib/private/open-webui"
          ]
          ++ optionals config.services.ollama.enable  [
            # unsure if one should be deleted or if they are both used
            "/var/lib/private/ollama"
            "/var/lib/ollama"
          ]
          ++ optionals config.services.colord.enable [
            {
              directory = "/var/lib/colord";
              user = "colord";
              group = "colord";
              mode = "u=rwx,g=rx,o=";
            }
          ]
          ++ optionals config.services.chrony.enable ["/var/lib/chrony"]
          ++ optionals config.services.kubo.enable [ # ipfs
            config.services.kubo.dataDir
          ]
          ++ optionals config.services.fwupd.enable [
            "/var/lib/fwup"
          ]
          ++ optionals config.services.home-assistant.enable [
            config.services.home-assistant.configDir
          ]
          ++ optionals config.services.hydra.enable [
            "/var/lib/hydra"
          ]
          ++ optionals config.services.mosquitto.enable [
            config.services.mosquitto.dataDir
          ]
          ++ optionals config.services.jellyfin.enable [
            "/var/lib/jellyfin"
          ]
          ++ optionals config.services.postgresql.enable [
            "/var/lib/postgresql"
          ]
          ++ optionals config.services.pgadmin.enable [
            "/var/lib/private/pgadmin"
          ]
          ++ optionals config.services.sshguard.enable [
            "/var/lib/sshguard"
          ]
          ++ optionals config.services.syncthing.enable [
            config.services.syncthing.dataDir
          ]
          ++ optionals config.services.zigbee2mqtt.enable [
            config.services.zigbee2mqtt.dataDir
          ]
          ++ optionals config.networking.wireless.iwd.enable [
            "/var/lib/iwd"
          ]
          ++ optionals config.networking.networkmanager.enable [
            "/var/lib/NetworkManager"
          ]
          ++ optionals config.virtualisation.waydroid.enable [
            "/var/lib/waydroid"
          ];
        files = [
          #"/etc/machine-id"
          {
            file = "/etc/nix/id_rsa";
            parentDirectory = {mode = "u=rwx,g=rx,o=rx";};
          }
        ];
      };
    };

    # works to force dir to exist!!
    systemd.tmpfiles.rules = [
      "d /persist/home/lriutzel 0700 lriutzel users"
      "d /persist/home/criutzel 0700 criutzel users"
    ]
    ++ optionals config.services.syncthing.enable [
      "d ${config.services.syncthing.dataDir} 0755 ${config.services.syncthing.user} ${config.services.syncthing.group}"
    ]
    ++ optionals config.services.home-assistant.enable [
      "d ${config.services.home-assistant.configDir} 0755 hass hass"
    ]
    ++ optionals config.services.mosquitto.enable [
      "d ${config.services.mosquitto.dataDir} 0755 mosquitto mosquitto"
    ]
    ++ optionals config.services.zigbee2mqtt.enable [
      "d ${config.services.zigbee2mqtt.dataDir} 0755 zigbee2mqtt zigbee2mqtt"
    ];

    # Trying to hide home-manager impermanence mounts
    #
    # Didn't work but keeping for reference. Maybe could work? From research
    # udisks can't affect fuse because it isn't a piece of hardware?
    #
    # Alternate solution: don't use home-manager impermanence, instead use nixos
    # module. Not ideal but from what I can tell. Fuse itself doesn't support
    # adding the mount hints we need to hide it. Tried/trying to add the
    # hints/attributes via another method.
    # https://github.com/nix-community/impermanence/issues/127
    #
    #services.udev.extraRules = ''
    #  # Hide bind mounts
    #  ACTION=="add", KERNEL=="fuse, SUBSYSTEM=="misc", ATTR{hint-ignore}=="udisks2", ENV{UDISKS_IGNORE}="1"
    #'';

  };
}
