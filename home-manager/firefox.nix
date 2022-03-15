{ config, pkgs, nixosConfig, lib, inputs, ... }:
{
  home.packages = with pkgs; lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) [
    ffmpeg # used for firefox va-api accel with media.rdd-ffmpeg
  ];

  xdg.mimeApps = {
    defaultApplications = {
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
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
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      darkreader
      ublock-origin
      bitwarden
      #decentraleyes
      localcdn #fork of decentraleyes
      i-dont-care-about-cookies
      #back-to-close-we
      #detect-cloudflare-plus # True Sight - track what content delievery networks are serving you
      sponsorblock
      snowflake
      old-reddit-redirect
      reddit-enhancement-suite
      ff2mpv
      link-cleaner
      markdownload
      #ipfs-companion
      #javascript-restrictor
    ];
    profiles = {
      lriutzel = {
        isDefault = true;
        settings = {
          "browser.startup.blankWindow" = true;
          "browser.startup.page" = 3; # Startup - Open previous windows and tabs
          "reader.color_scheme" = "dark";
          "reader.font_size" = 7;
          "reader.content_width" = 3;
          "browser.aboutConfig.showWarning" = false; # don't warn hakrz
          "browser.urlbar.placeholderName" = "style"; # Search with style or enter address
          "ui.systemUsesDarkTheme" = true; # Dark mode
          "browser.in-content.dark-mode" = true; # Dark mode
          "devtools.theme" = "dark";
          #"widget.content.gtk-theme-override" = "Nordic";
          # Enable userContent.css and userChrome.css for our theme modules
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          # Don't use the built-in password manager; a nixos user is more likely
          # using an external one (you are using one, right?).
          "signon.rememberSignons" = false;
          "signon.autofillForms" = false; # Disable built-in form-filling
          # Do not check if Firefox is the default browser
          "browser.shell.checkDefaultBrowser" = false;
          # Disable the "new tab page" feature and show a blank tab instead
          # https://wiki.mozilla.org/Privacy/Reviews/New_Tab
          # https://support.mozilla.org/en-US/kb/new-tab-page-show-hide-and-customize-top-sites#w_how-do-i-turn-the-new-tab-page-off
          "browser.newtabpage.enabled" = false;
          "browser.newtab.url" = "about:blank";
          # Disable Activity Stream
          # https://wiki.mozilla.org/Firefox/Activity_Stream
          "browser.newtabpage.activity-stream.enabled" = false;
          # Disable new tab tile ads & preload
          # http://www.thewindowsclub.com/disable-remove-ad-tiles-from-firefox
          # http://forums.mozillazine.org/viewtopic.php?p=13876331#p13876331
          # https://wiki.mozilla.org/Tiles/Technical_Documentation#Ping
          # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-source
          # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-ping
          "browser.newtabpage.enhanced" = false;
          "browser.newtab.preload" = false;
          "browser.newtabpage.directory.ping" = "";
          "browser.newtabpage.directory.source" = "data:text/plain,{}";
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # Disable top stories
          "browser.newtabpage.activity-stream.feeds.sections" = false;
          "browser.newtabpage.activity-stream.feeds.system.topstories" = false; # Disable top stories
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false; # Disable pocket

          # Disable some not so useful functionality.
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "extensions.htmlaboutaddons.discover.enabled" = false;
          "extensions.pocket.enabled" = false;
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";
          "extensions.shield-recipe-client.enabled" = false;
          "app.shield.optoutstudies.enabled" = false;
          # Disable battery API
          # https://developer.mozilla.org/en-US/docs/Web/API/BatteryManager
          # https://bugzilla.mozilla.org/show_bug.cgi?id=1313580
          "dom.battery.enabled" = false;
          # Disable "beacon" asynchronous HTTP transfers (used for analytics)
          # https://developer.mozilla.org/en-US/docs/Web/API/navigator.sendBeacon
          "beacon.enabled" = false;
          # Disable pinging URIs specified in HTML <a> ping= attributes
          # http://kb.mozillazine.org/Browser.send_pings
          "browser.send_pings" = false;
          # Disable gamepad API to prevent USB device enumeration
          # https://www.w3.org/TR/gamepad/
          # https://trac.torproject.org/projects/tor/ticket/13023
          "dom.gamepad.enabled" = false;
          # Don't try to guess domain names when entering an invalid domain name in URL bar
          # http://www-archive.mozilla.org/docs/end-user/domain-guessing.html
          "browser.fixup.alternate.enabled" = false;
          # Disable telemetry
          # https://wiki.mozilla.org/Platform/Features/Telemetry
          # https://wiki.mozilla.org/Privacy/Reviews/Telemetry
          # https://wiki.mozilla.org/Telemetry
          # https://www.mozilla.org/en-US/legal/privacy/firefox.html#telemetry
          # https://support.mozilla.org/t5/Firefox-crashes/Mozilla-Crash-Reporter/ta-p/1715
          # https://wiki.mozilla.org/Security/Reviews/Firefox6/ReviewNotes/telemetry
          # https://gecko.readthedocs.io/en/latest/browser/experiments/experiments/manifest.html
          # https://wiki.mozilla.org/Telemetry/Experiments
          # https://support.mozilla.org/en-US/questions/1197144
          # https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/preferences.html#id1
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "experiments.supported" = false;
          "experiments.enabled" = false;
          "experiments.manifest.uri" = "";
          # Disable health reports (basically more telemetry)
          # https://support.mozilla.org/en-US/kb/firefox-health-report-understand-your-browser-perf
          # https://gecko.readthedocs.org/en/latest/toolkit/components/telemetry/telemetry/preferences.html
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;

          # skip homepage when starting
          "browser.search.firstRunSkipsHomepage" = true;
          # allow use of system gtk dark theme
          "widget.content.allow-gtk-dark-theme" = true;

          "media.eme.enabled" = true; # Enable DRM
          "media.gmp-widevinecdm.visible" = true; # Enable DRM
          "media.gmp-widevinecdm.enabled" = true; # Enable DRM
        };
      };
    };

    #extraPolicies = {
    #  CaptivePortal = true;
    #  DisableFirefoxStudies = true;
    #  DisablePocket = true;
    #  DisableTelemetry = true;
    #  DisableFirefoxAccounts = false;
    #  FirefoxHome = {
    #    Pocket = false;
    #    Snippets = false;
    #  };
    #   UserMessaging = {
    #     ExtensionRecommendations = false;
    #     SkipOnboarding = true;
    #   };
    #};

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
