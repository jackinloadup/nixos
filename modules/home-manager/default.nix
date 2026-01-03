# flake-parts module
{ inputs
, ...
}:
{
  flake = {
    homeModules = {
      common = {
        imports = [
          ./alacritty.nix
          ./base.nix
          ./dunst.nix
          ./firefox.nix
          ./foot.nix
          ./gpg.nix
          ./mpv.nix
          ./music.nix
          ./nix.nix
          ./openrct2.nix
          ./starship.nix
          ./task-warrior
          ./zoom.nix
        ];
      };
      tui.imports = [
        ./bash.nix
        ./tui.nix
        ./zsh.nix
        inputs.nixvim.homeModules.nixvim
      ];

      gui.imports = [
        ./development.nix
        ./graphical.nix
        ./kitty.nix
        ./satellite-images.nix
        #./i3.nix
        ./nixvim
        ./noctalia.nix
        ./sway
        ./syncthing.nix
        ./waybar.nix
        ./xorg.nix
      ];

      video-editor.imports = [
        ./video-editor.nix
      ];
      #common-linux = {
      #  imports = [
      #    self.homeModules.common
      #    ./bash.nix
      #    ./vscode-server.nix
      #  ];
      #};
      #common-darwin = {
      #  imports = [
      #    self.homeModules.common
      #    ./zsh.nix
      #    ./bash.nix
      #    # ./kitty.nix
      #    # ./emacs.nix
      #  ];
      #};
    };
  };
}
