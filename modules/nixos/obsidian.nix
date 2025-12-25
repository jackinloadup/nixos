{ lib, pkgs, ... }:
let
  inherit (lib) getExe mkDefault;
in
{
  config = {

    home-manager.sharedModules = [
      ({ config, ... }: {
        home.packages = [
          # conflicted with k3s, which provides a variation of the package
          #pkgs.kubectl
          pkgs.k3s
          pkgs.istioctl
          pkgs.dbeaver-bin # database gui
          pkgs.claude-monitor # monitor claude use
        ];

        programs.claude-code.enable = true;
        programs.k9s.enable = true; # Kubernetes CLI To Manage Your Clusters In Style

        programs.zoom-us.enable = false; #  didn't work with niri
        programs.firefox.profiles."${config.home.username}".extensions.packages = [
          # automatically select to use zoom in browser
          pkgs.nur.repos.rycee.firefox-addons.zoom-redirector
        ];

        xdg.desktopEntries.gather =
          let
            url = "https://app.v2.gather.town/app/obsidian-3812d4d3-1a3e-4e30-b603-b31c7b22e94f/join";
            icon = builtins.fetchurl {
              url = "https://framerusercontent.com/images/P5hrzskVvpcfIIXVKNXfzAkXLw.png";
              sha256 = "7c089864357290503eafa7ad216d78a6d4118ae70d07683745e1db1c7893e4c2";
            };
            chromium = getExe config.programs.chromium.package;
          in
          {
            name = "Gather";
            genericName = "Gather";
            comment = "Open Gather in a chromeless browser";
            exec = "${pkgs.systemd}/bin/systemd-cat --identifier=gather-browser ${chromium} --app=${url}";
            inherit icon;
            terminal = false;
            categories = [
              "Utility"
            ];
          };
      })
    ];

    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%"
        "--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%"
        "--disable=traefik"
      ];
    };

    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = mkDefault true;
  };
}
