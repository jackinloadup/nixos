{ pkgs, ... }: {
  config = {
    environment.systemPackages = [
      pkgs.wev # listen to keyboard mouse events
      pkgs.wdisplays
      pkgs.wlr-randr
      pkgs.wlrctl # control mouse keyboard windows
      pkgs.wl-clipboard-rs # wl-copy
      pkgs.cliphist # clipboard history for clipper plugin
    ];

    # try these again later. Spent minimal time playing with them
    #services.ringboard.wayland.enable = true; # clipboard manager
    #programs.wshowkeys.enable = true; # show pressed keys on screen for others
  };
}
