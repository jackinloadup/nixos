{ pkgs, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  config = {
    #programs.bash.enable = true;

    programs.carapace.enable = true;

    programs.htop.enable = true;
    #home.file."${config.xdg.configHome}/htop/htoprc".source = ./htoprc;
    #xdg.configFile = {
    #  source = ./htoprc;
    #  target = "htop/hotprc";
    #};

    programs.readline = {
      enable = true;
      bindings = {
        "\\C-h" = "backward-kill-word";
      };
      extraConfig = ''
        set editing-mode vi

        set show-mode-in-prompt on
        set vi-ins-mode-string "\1\e[5 q\2"
        set vi-cmd-mode-string "\1\e[2 q\2"

        set keymap vi-command
        # j and k should search for the string of characters preceding the cursor
        "k": history-search-backward
        "j": history-search-forward

        set keymap vi-insert
        # inoremap jk <Esc>
        "jk": vi-movement-mode
      '';
    };
    programs.zoxide.enable = true;

    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ]; # Keep up-arrow for history-substring-search
      settings = {
        style = "compact";
        inline_height = 20;
      };
    };


    home.packages = [
      # Debug / system info
      pkgs.iotop
      pkgs.inetutils
      pkgs.usbutils # an alternative could be busybox cope toybox
      pkgs.hwloc # can show hardware topo with lstopo
    ];

    # Needed for vars like XGD_STATE_HOME
    xdg.enable = mkDefault true;
  };
}
