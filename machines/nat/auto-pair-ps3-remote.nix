{ self, inputs, pkgs, lib, ... }:

{
  systemd.services.pairRemote = let 
    script = pkgs.writeShellScript "connect-ps3-bd-remote" ''
MAC="64:D4:BD:6A:9C:8E"

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

while true
do
    sleep 1
    if [ $(powered) = yes ] && [ $(connected) = no ]; then
        echo "connect ''${MAC}" | ${pkgs.bluez}/bin/bluetoothctl &> /dev/null
        sleep 5
    fi
done
      '';
  in {
    description = "Pair PS3 BD Remote";

    conflicts = [ "shutdown.target" "sleep.target" ];
    before = [ "shutdown.target" "sleep.target" ];
    after = [ "bluetooth.service" ];
    wantedBy = [ "graphical.target" ];
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
