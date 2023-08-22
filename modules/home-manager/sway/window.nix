{
  titlebar = true;
  hideEdgeBorders = "smart";

  commands = [
    {
      command = "inhibit_idle fullscreen";
      criteria.class = "firefox";
    }
    {
      command = "inhibit_idle fullscreen";
      criteria.app_id = "mpv";
    }
    {
      command = "inhibit_idle fullscreen";
      criteria.class = "LBRY";
    }
    {
      command = "inhibit_idle fullscreen";
      criteria.class = "Kodi";
    }
    {
      # spotify doesn't set its WM_CLASS until it has mapped, so the assign is not reliable
      command = "move --no-auto-back-and-forth window to workspace 10";
      criteria.class = "Spotify";
    }
    #{
    #  command = "opacity ${builtins.toString theme.background_opacity}";
    #  criteria.app_id = "firefox";
    #}
    #{
    #  command = "move to scratchpad";
    #  criteria = {
    #    app_id = "org.keepassxc.KeePassXC";
    #    title = "^Passwords.kdbx";
    #  };
    #}
  ];
}
