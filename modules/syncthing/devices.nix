# Syncthing device registry
# All known devices across the fleet (and external devices like TrueNAS)
#
# Usage: Import and reference by name in folder configs
# Note: Syncthing automatically ignores the local device ID, so it's safe
# to include all devices everywhere.
{
  # Machines in this flake
  reg-system = {
    id = "BAF3YBH-RUCAMPA-WJHNHOR-DLRO3SY-O5VPB2L-Z72PSDF-BMLUEK2-CULPDA6";
  };
  reg-user = {
    id = "QVIA4IP-UKSWJMW-PW4XZA7-V6WQXTZ-UYZEDUL-PL6ACAZ-KVKERQR-36K4EAJ";
  };
  riko = {
    id = "MKNUHJO-P7DTQMA-UOP4CWS-VNI3NUW-MZZHVHR-ESWRGI2-7HU7D3N-VF5CKAY";
  };
  riko-lriutzel = {
    id = "PEX4JI3-3B6Q72H-TOB5KEE-FDNSU4B-BD2YMCE-GAWEZAK-MFSW4V5-DHTZUQB";
  };
  zen = {
    id = "WFGWLXY-EBWWSM6-DD24MRK-MNJXQC2-XKPO2SO-E4B5IWU-ERABVMW-2BYO4QW";
  };
  kanye-criutzel = {
    id = "4DMVVUD-25IEEXB-7BBMCOH-6CQIDIL-7R7A4GX-YM5XE2P-43BCSLB-CHZCDQJ";
  };
  jesus-criutzel = {
    id = "SIAXUJG-YWHSN2I-2D2P5UO-6QDA7VN-NN7PXCK-C77UHGN-MYZXO35-HSOXFA4";
  };

  # External devices
  truenas = {
    id = "NRRICJD-QXJLVHR-AHNX2Y5-GL2BOQV-XV3GFHP-NLRPJ5P-TWSCK4I-LAXTRAE";
  };

  # Mobile devices
  pixel-6-pro = {
    id = "HPZTWQ5-EMUASI5-OZBGDW6-HLQQ27G-6XPNEZX-J5KBKXN-45GNDF6-VTHPSQO";
  };

}
