{ lib
, ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) listOf enum;
  username = "lriutzel";
in
{


  # Make user available in user list
  options.machine.users = mkOption {
    type = listOf (enum [ username ]);
  };

  config = { };
}
