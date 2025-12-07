{ pkgs, ... }: {
  config = {
    environment.systemPackages = [
      pkgs.wev # listen to keyboard mouse events
      pkgs.wdisplays
      pkgs.wlr-randr
      pkgs.wlrctl # control mouse keyboard windows
    ];
  };
}
