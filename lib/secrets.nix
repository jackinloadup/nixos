_:
let
  inherit (builtins) attrNames elem readDir pathExists;
in
rec {
  machines = attrNames (readDir ../machines);
  hostExists = name: elem name machines;
  hostHasService = name: service: pathExists (../machines/${name}/${service});

  smachines = attrNames (readDir ../secrets/machines);
  shostExists = name: elem name smachines;
  shostHasService = name: service: pathExists (../secrets/machines/${name}/${service});

  # Devices (phones, external clients) - secrets/devices/
  sdevices = if pathExists ../secrets/devices then attrNames (readDir ../secrets/devices) else [ ];
  sdeviceExists = name: elem name sdevices;
}
