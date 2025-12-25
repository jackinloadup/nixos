{ pkgs, flake, ... }:
let
  username = "lriutzel";
in
{
  imports = [
    #flake.inputs.self.nixosModules.hyprland
    flake.inputs.self.nixosModules.windowManagers
  ];

  config = {
    users.users."${username}".extraGroups = [
      "audio"
      "video"
      "adbusers"
    ];

    hardware.logitech.wireless.enableGraphical = true;

    #environment.pathsToLink =
    #  "${pkgs.gnome.gnome-backgrounds}" # Backgrounds for GNOME used in sway. Needs to be set at system level
    #];

    #programs.captive-browser.enable = true;
    programs.chromium.enable = true;

    home-manager.users."${username}" =
      {
        imports = [
          flake.self.homeModules.gui
          ./gnome.nix
        ];

        #home.persistence."/persist/home/${username}".enable = true;
        #programs.waybar.settings."custom/pkgwatt" = {
        #  format = "{} Watts";
        #  max-length = 7;
        #  interval = 10;
        #  exec = pkgs.writeShellScript "pkgs-watts" ''
        #    sudo turbostat --Summary --quiet --show PkgWatt --num_iterations 1 | sed -n 2p
        #  '';
        #};

        #programs.neovim.enable = true;

        programs.mpv.enable = true;
        programs.firefox.enable = true;

        # unofficial bitwarden cli
        #programs.rbw = {
        #  enable = true;
        #  settings = {
        #    inherit email;
        #    lock_timeout = 300;
        #    pinentry = "gnome3";
        #  };
        #};

        services.mopidy.enable = true;

        #stylix.image = /home/lriutzel/Pictures/background.jpg;
        home.packages = [
          pkgs.bc
          #pkgs.pipexec # a neat tool to help with named pipes
          pkgs.emulsion # mimimal linux image viewer built in rust
          pkgs.imv # minimal image viewer
          pkgs.zathura # PDF / Document viewer
          # pkgs.zeal # documentation browser

          pkgs.file-roller # Archive manager

          pkgs.kitty
          pkgs.libfido2 # interact with fido2 tokens

          pkgs.speedcrunch # gui calculator

          # alt browser with ipfs builtin
          pkgs.brave

          ## fast adds chromium
          #fast-cli # bandwidth test through fast.com
          pkgs.nmap

          ## Audio
          pkgs.playerctl # TUI

          pkgs.luminance # Display brightness

          # Fun
          pkgs.asciiquarium # Fun aquarium animation
          pkgs.cmatrix # Fun matrix animation
          pkgs.nms # https://github.com/bartobri/no-more-secrets
          #pkgs.cava # Console-based Audio Visualizer for Alsa # build failure
          pkgs.nsnake # snake game
          pkgs.terminal-parrot # parrot in your terminal
          pkgs.pipes-rs # pipes terminal screensaver
          # https://tattoy.sh/ not yet in nixpkgs
        ];
      };
  };
}
