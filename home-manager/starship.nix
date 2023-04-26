{ config, pkgs, ... }:

let
  inherit (lib) mkIf concatStrings;
in {
  config = {
    programs.starship = mkIf config.programs.starship.enable {
      package = pkgs.starship;

      settings = {
        format = concatStrings [
          "$time"
          "$username"
          "$hostname"
          "$character"
        ];
        right_format = concatStrings [
          "$all"
        ];
        scan_timeout = 10;
        add_newline = false;
        line_break = {
          disabled = true;
        };
        time = {
          disabled = false;
          time_format = "%l:%M%p";
          utc_time_offset = "-5";
          format = "$time($style) ";
        };
        username = {
          disabled = false;
        };
        aws = { 
          format = "on [$symbol($profile )(\($region\) )]($style)";
          style = "bold blue";
          symbol = "🅰 ";
          region_aliases = {
            us-east-1 = "va";
            us-west-1 = "utah";
          };
          profile_aliases = {
            CompanyGroupFrobozzOnCallAccess = "Frobozz";
          };
        };
      };
    };
  };
}
