{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkDefault mkIf mkOption mkOrder getExe types literalExpression;
  inherit (builtins) hasAttr;
  cfg = config.boot.initrd.network.tor;
  torRc = pkgs.writeText "tor.rc" ''
    DataDirectory /etc/tor
    SOCKSPort 127.0.0.1:9050 IsolateDestAddr
    SOCKSPort 127.0.0.1:9063
    HiddenServiceDir /etc/tor/onion/bootup
    HiddenServicePort 22 127.0.0.1:22
  '';
in
{
  options.boot.initrd.network.tor = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Enable Tor support in the initrd

        This will start tor during boot and create a onion service for ssh access.

        You need 3 files to create an onion id (a.k.a. tor hidden service).
          * hostname
          * hs_ed25519_public_key
          * hs_ed25519_secret_key
        These should be placed in a folder that is passed to the initrd via `boot.initrd.secrets`.
        For example:
        ```
          boot.initrd.secrets = {
            "/etc/tor/onion/bootup" = /home/tony/tor/onion; # maybe find a better spot to store this.
          };
        ```
      '';
    };
    package = mkOption {
      type = types.package;
      default = config.services.tor.package;
      defaultText = literalExpression "services.tor.package";
      description = lib.mdDoc ''
        The package used for the tor service.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasAttr "/etc/tor/onion/bootup" config.boot.initrd.secrets;
        message = "boot.initrd.secrets.\"/etc/tor/onion/bootup\" is unset. tor service files must be set..";
      }
      {
        assertion = config.boot.initrd.network.enable || config.boot.initrd.systemd.network.enable;
        message = "boot.initrd.network.enable or boot.initrd.systemd.network.enable must be true for tor services to work";
      }
    ];

    boot.initrd.network.ntpd.enable = mkDefault true;
    boot.initrd.network.haveged.enable = mkDefault true;

    # start tor during boot process
    boot.initrd.network.postCommands = mkOrder 600 ''
      echo "tor: preparing onion folder"
      # have to do this otherwise tor does not want to start
      chmod -R 700 /etc/tor

      echo "make sure localhost is up"
      ip a a 127.0.0.1/8 dev lo
      ip link set lo up
      echo "tor: starting tor"

      ${getExe cfg.package} -f ${torRc} --verify-config
      ${getExe cfg.package} -f ${torRc} &
    '';

    # copy tor to you initrd
    boot.initrd.extraUtilsCommands = mkOrder 400 ''
      copy_bin_and_libs ${getExe cfg.package}
    '';
    boot.initrd.systemd = {
      extraBin = {
        tor = "${getExe cfg.package}";
      };
      storePaths = [ torRc ];

      services.tor = {
        description = "Tor Daemon";

        wantedBy = [ "initrd.target" ];
        conflicts = [ "basic.target" ];
        after = [ "network.target" "initrd-nixos-copy-secrets.service" "ntpd.service" "haveged.service" ];

        preStart = ''
          /bin/chmod 0600 "/etc/tor/onion/bootup"
        '';

        unitConfig.DefaultDependencies = false;

        serviceConfig = {
          Type = "simple";
          KillMode = "process";
          # Stage 1 doesn't have users
          #User = "tor";
          #Group = "tor";

          #ExecStartPre = [
          #  "${cfg.package}/bin/tor -f ${torRc} --verify-config"
          #  # DOC: Appendix G of https://spec.torproject.org/rend-spec-v3
          #  #("+" + pkgs.writeShellScript "ExecStartPre" (concatStringsSep "\n" (flatten (["set -eu"] ++
          #  #  mapAttrsToList (name: onion:
          #  #    optional (onion.authorizedClients != []) ''
          #  #      rm -rf ${escapeShellArg onion.path}/authorized_clients
          #  #      install -d -o tor -g tor -m 0700 ${escapeShellArg onion.path} ${escapeShellArg onion.path}/authorized_clients
          #  #    '' ++
          #  #    imap0 (i: pubKey: ''
          #  #      echo ${pubKey} |
          #  #      install -o tor -g tor -m 0400 /dev/stdin ${escapeShellArg onion.path}/authorized_clients/${toString i}.auth
          #  #    '') onion.authorizedClients ++
          #  #    optional (onion.secretKey != null) ''
          #  #      install -d -o tor -g tor -m 0700 ${escapeShellArg onion.path}
          #  #      key="$(cut -f1 -d: ${escapeShellArg onion.secretKey} | head -1)"
          #  #      case "$key" in
          #  #       ("== ed25519v"*"-secret")
          #  #        install -o tor -g tor -m 0400 ${escapeShellArg onion.secretKey} ${escapeShellArg onion.path}/hs_ed25519_secret_key;;
          #  #       (*) echo >&2 "NixOS does not (yet) support secret key type for onion: ${name}"; exit 1;;
          #  #      esac
          #  #    ''
          #  #  ) cfg.relay.onionServices ++
          #  #  mapAttrsToList (name: onion: imap0 (i: prvKeyPath:
          #  #    let hostname = removeSuffix ".onion" name; in ''
          #  #    printf "%s:" ${escapeShellArg hostname} | cat - ${escapeShellArg prvKeyPath} |
          #  #    install -o tor -g tor -m 0700 /dev/stdin \
          #  #     ${runDir}/ClientOnionAuthDir/${escapeShellArg hostname}.${toString i}.auth_private
          #  #  '') onion.clientAuthorizations)
          #  #  cfg.client.onionServices
          #  #))))
          #];
          ExecStart = "${cfg.package}/bin/tor -f ${torRc}";
          #ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          #KillSignal = "SIGINT";
          #TimeoutSec = cfg.settings.ShutdownWaitLength + 30; # Wait a bit longer than ShutdownWaitLength before actually timing out
          Restart = "on-failure";
          LimitNOFILE = 32768;
          RuntimeDirectory = [
            # g+x allows access to the control socket
            "tor"
            "tor/root"
            # g+x can't be removed in ExecStart=, but will be removed by Tor
            "tor/ClientOnionAuthDir"
          ];
          RuntimeDirectoryMode = "0710";
          StateDirectoryMode = "0700";
          StateDirectory = [
            "tor"
            "tor/onion"
          ];
          #++
          #flatten (mapAttrsToList (name: onion:
          #  optional (onion.secretKey == null) "tor/onion/${name}"
          #) cfg.relay.onionServices);
          # The following options are only to optimize:
          # systemd-analyze security tor
          #RootDirectory = runDir + "/root";
          #RootDirectoryStartOnly = true;
          #InaccessiblePaths = [ "-+${runDir}/root" ];
          UMask = "0066";
          #BindPaths = [ stateDir ];
          #BindReadOnlyPaths = [ storeDir "/etc" ];
          # ++
          # optionals config.services.resolved.enable [
          #   "/run/systemd/resolve/stub-resolv.conf"
          #   "/run/systemd/resolve/resolv.conf"
          # ];
          #AmbientCapabilities   = [""] ++ lib.optional bindsPrivilegedPort "CAP_NET_BIND_SERVICE";
          #CapabilityBoundingSet = [""] ++ lib.optional bindsPrivilegedPort "CAP_NET_BIND_SERVICE";
          # ProtectClock= adds DeviceAllow=char-rtc r
          ###DeviceAllow = "";
          ###LockPersonality = true;
          ###MemoryDenyWriteExecute = true;
          ###NoNewPrivileges = true;
          ###PrivateDevices = true;
          ###PrivateMounts = true;
          ###PrivateNetwork = mkDefault false;
          ###PrivateTmp = true;
          #### Tor cannot currently bind privileged port when PrivateUsers=true,
          #### see https://gitlab.torproject.org/legacy/trac/-/issues/20930
          ####PrivateUsers = !bindsPrivilegedPort;
          ###ProcSubset = "pid";
          ###ProtectClock = true;
          ###ProtectControlGroups = true;
          ###ProtectHome = true;
          ###ProtectHostname = true;
          ###ProtectKernelLogs = true;
          ###ProtectKernelModules = true;
          ###ProtectKernelTunables = true;
          ###ProtectProc = "invisible";
          ###ProtectSystem = "strict";
          ###RemoveIPC = true;
          ###RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
          ###RestrictNamespaces = true;
          ###RestrictRealtime = true;
          ###RestrictSUIDSGID = true;
          # See also the finer but experimental option settings.Sandbox
          SystemCallFilter = [
            "@system-service"
            # Groups in @system-service which do not contain a syscall listed by:
            # perf stat -x, 2>perf.log -e 'syscalls:sys_enter_*' tor
            # in tests, and seem likely not necessary for tor.
            "~@aio"
            "~@chown"
            "~@keyring"
            "~@memlock"
            "~@resources"
            "~@setuid"
            "~@timer"
          ];
          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";
        };
      };
    };
  };
}
