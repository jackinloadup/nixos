{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
  inherit (lib) mkOption mkIf mkDefault mkOverride optionals elem getExe;
  inherit (lib.types) listOf enum;

  first_and_last = "Lucas Riutzel";
  username = "lriutzel";
in {
  config = {
    users.users."${username}" = {
      description = first_and_last;
      shell = pkgs.zsh;
      useDefaultShell = false; # used with  users.defaultUserShell
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "input"
        "networkmanager"
      ];
    };
    nix.settings.trusted-users = [username];

    hardware.solo2.enable = true;
    hardware.yubikey.enable = true;

    programs.command-not-found.enable = true;
    programs.yazi.enable = true;

    home-manager.users."${username}" = let
      homeDir = "/home/${username}";
    in {
      imports = [
          flake.self.homeModules.common
          ./ssh.nix
          flake.inputs.nix-index-database.homeModules.nix-index
          flake.self.homeModules.tui
      ]
      ++ optionals config.machine.impermanence [
        ./impermanence.nix
      ];

      home.username = username;
      home.homeDirectory = mkOverride 10 homeDir;

      # pretty sure this is disable because useDefaultShell = false; doesn't
      # resolve some issue I was having
      #programs.bash.enable = true;
      # The 'programs.command-not-found.enable' option is mutually exclusive
      # with the 'programs.nix-index.enableBashIntegration' option.
      #programs.command-not-found.enable = true;

      programs.nix-index.enable = true;
      #programs.nix-index.enableBashIntegration = config.programs.bash.enable;
      programs.nix-index.enableZshIntegration = config.programs.zsh.enable;
      programs.nix-index-database.comma.enable = true;

      programs.fzf.enable = true;

      programs.ssh.enable = true;
      programs.starship.enable = true;
      programs.zsh.enable = true;

      # per https://github.com/solokeys/solo2/discussions/108#discussioncomment-12253610
      # gpg doesn't support resident keys
      #services.gpg-agent.enable = true;
      # is the agent needed anyway with services.gpg-agent?
      # yes, gpg-agent doesn't support resident keys. at least not the solo2.
      services.ssh-agent.enable = true;

      home.packages = [
          pkgs.isd # systemd tui

          #pkgs.inxi # cli extensive system information

          #pkgs.unzip # duh
          pkgs.lftp # ftp client
          pkgs.terminal-colors # print all the terminal colors

          # unar is HUGE at 930mb
          #pkgs.unar # An archive unpacker program GUI & TUI
          pkgs.units

          pkgs.sad # tool to search and replace
          pkgs.jless # json viewer
          pkgs.tealdeer # $tldr strace
          pkgs.nota # fancy cli calculator
          pkgs.bitwarden-cli
          pkgs.yt-dlp # there is an alt youtube-dl-lite
          pkgs.xdg-utils # for xdg-open
          pkgs.xdg-user-dirs # command to get the path to Downloads/Pictures/ect
          #nur.repos.ambroisie.comma # like nix-shell but more convinient
          pkgs.nixos-shell
          #  attribute 'default' missing
          #flake.inputs.nix-inspect.packages.default

          # TUI to GUI helpers
          pkgs.bfs # breadth-first version of the UNIX find command. might be faster than fd?
          pkgs.broot # tree directory viewer
          #pkgs.dragon-drop # in unstable its maybe xdragon

          ## networking
          pkgs.nethogs
          pkgs.ngrep

          ## spreadsheet stuffs
          #pkgs.sc-im # disabled due to insecure dependency: libxls-1.6.2
          #pkgs.visidata

          pkgs.systemctl-tui # tui for systemd

          pkgs.television # blazingly fast general purpose fuzzy finder
          #pkgs.doxx # document viewer

          # todoist # task manager
          # gping
          # impala # wifi tui
          # cms # audio/podcast?
          # tdf # PDF viewer
          # jqp # jq playground tui
          # rainfrog # tui database management
          # parallama # llm interface
          # wikitui # wikipedia tui
          # mc # midnight commander. file manager, haven't quite picked this up yet
          # somo # easier tcp/udp ports ect

          # mprocs # run multiple log running commands at once and see output
          # presenterm # Presentations
      ];

    };
  };

}
