{ config, pkgs, nixosConfig, lib, inputs, ... }:
{
  home.packages = with pkgs; lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) [
    ffmpeg # used for firefox va-api accel with media.rdd-ffmpeg
  ];

  xdg.mimeApps = {
    defaultApplications = {
      "application/xhtml+xml" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };

  programs.firefox = {
    enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
    package = pkgs.firefox-bin;
    #package = pkgs.wrapFirefox pkgs.firefox-esr {
    #  nixExtensions = [
    #    (pkgs.fetchFirefoxAddon {
    #      name = "ublock"; # Has to be unique!
    #      url = "https://addons.mozilla.org/firefox/downloads/file/3679754/ublock_origin-1.31.0-an+fx.xpi";
    #      sha256 = "1h768ljlh3pi23l27qp961v1hd0nbj2vasgy11bmcrlqp40zgvnr";
    #    })
    #  ];

    #  extraPolicies = {
    #    CaptivePortal = false;
    #    DisableFirefoxStudies = true;
    #    DisablePocket = true;
    #    DisableTelemetry = true;
    #    DisableFirefoxAccounts = true;
    #    FirefoxHome = {
    #      Pocket = false;
    #      Snippets = false;
    #    };
    #     UserMessaging = {
    #       ExtensionRecommendations = false;
    #       SkipOnboarding = true;
    #     };
    #  };

    #  extraPrefs = ''
    #    // Show more ssl cert infos
    #    lockPref("security.identityblock.show_extended_validation", true);
    #  '';
    #};
    #package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    #  #ffmpegSupport = true;
    #  #pipewireSupport = true;
    #  forceWayland = true;
    #  #extraPolicies = {
    #  #  ExtensionSettings = {};
    #  #};
    #};
  };
}
