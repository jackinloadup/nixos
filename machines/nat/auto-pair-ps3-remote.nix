{ self
, inputs
, pkgs
, lib
, ...
}:
# TODO make this a user service
{
  systemd.services.pairRemote =
    let
      script = pkgs.writeShellScript "connect-ps3-bd-remote" ''
        powered() {
          echo "show" \
          | ${pkgs.bluez}/bin/bluetoothctl \
          | ${pkgs.gnugrep}/bin/grep "Powered" \
          | ${pkgs.coreutils-full}/bin/cut -d " " -f 2
        }

        connected() {
          echo "info ''${MAC}" \
          | ${pkgs.bluez}/bin/bluetoothctl \
          | ${pkgs.gnugrep}/bin/grep "Connected" \
          | ${pkgs.coreutils-full}/bin/cut -d " " -f 2
        }

        connect() {
          echo "connect ''${MAC}" \
          | ${pkgs.bluez}/bin/bluetoothctl &> /dev/null
        }

        main() {
          local MAC="64:D4:BD:6A:9C:8E"
          local PREV_CONNECTED="no"

          echo "Started"

          while true
          do

              local POWERED=$(powered)
              local CONNECTED=$(connected)

              if [ $POWERED = yes ] && [ $CONNECTED = no ]; then
                $(connect)

                # wait at least 5 seconds before trying again
                sleep 5
              elif [ $POWERED = yes ] && [ $CONNECTED = yes ]; then
                # if the remote is connected wait 1m before checking again
                sleep 1m
              fi

              if [ $PREV_CONNECTED = "no" ] && [ $CONNECTED = yes ]; then
                echo "Remote connected"
                PREV_CONNECTED="yes"
              elif [ $PREV_CONNECTED = "yes" ] && [ $CONNECTED = no ]; then
                echo "Remote disconnected"
                PREV_CONNECTED="no"
              fi

              # Ensure loop doesn't happen too often
              sleep 1
          done
        }

        main
      '';
    in
    {
      description = "Pair PS3 BD Remote";

      conflicts = [ "shutdown.target" "sleep.target" ];
      before = [ "shutdown.target" "sleep.target" ];
      after = [ "bluetooth.service" ];
      wantedBy = [ "multi-user.target" ];
      # due to getty/sway we never get to graphical.target
      #wantedBy = [ "graphical.target" ];
      serviceConfig = {
        # simple and not oneshot, otherwise ExecStop is not used
        Type = "simple";
        Nice = 19;
        IOSchedulingClass = "idle";
        ExecStart = "${script}";
        Restart = "always";
      };
    };
}
