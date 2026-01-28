{ lib
, config
, ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.programs.claude-code.enable {
    xdg.configFile."claude/settings.json".text = builtins.toJSON {
      env = {
        API_TIMEOUT_MS = "300000"; # 5 minutes
        BASH_DEFAULT_TIMEOUT_MS = "1800000"; # 30 minutes
        BASH_MAX_TIMEOUT_MS = "7200000"; # 120 minutes
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "true";
        DISABLE_TELEMETRYi = "1"; #
      };
    };
  };
}
