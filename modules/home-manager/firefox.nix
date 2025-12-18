{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf; #makeDesktopItem;
  inherit (lib.attrsets) genAttrs;
in {
  config = mkIf config.programs.firefox.enable {
    home.packages = [
      pkgs.speechd # for speech synthesis
      pkgs.ffmpeg # used for firefox va-api accel with media.rdd-ffmpeg
      #(makeDesktopItem { # convience alias to open a private window
      #  name = "firefox-private";
      #  desktopName = "Firefox (Private)";
      #  genericName = "Open a private Firefox window";
      #  icon = "firefox";
      #  exec = "${pkgs.firefox-bin}/bin/firefox --private-window";
      #  categories = [ "Network" ];
      #})
    ];

    xdg.mimeApps = {
      defaultApplications = genAttrs [
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/x-extension-xht"
        "application/x-extension-xhtml"
        "application/xhtml+xml"
        "text/html"
        "x-scheme-handler/chrome"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ] (name: "firefox.desktop");
    };

    wayland.windowManager.sway.config.floating.criteria = [
      {
        app_id = "firefox";
        title = "Firefox - Sharing Indicator";
      }
      {
        app_id = "firefox";
        title = "Firefox — Sharing Indicator";
      }
      {
        app_id = "firefox";
        title = "Picture-in-Picture";
      }
    ];

    programs.firefox = {
      package = pkgs.firefox-bin;
      #package = pkgs.wrapFirefox pkgs.firefox-esr {
      #  nixExtensions = [
      #    (pkgs.fetchFirefoxAddon {
      #      name = "ublock"; # Has to be unique!
      #      url = "https://addons.mozilla.org/firefox/downloads/file/3679754/ublock_origin-1.31.0-an+fx.xpi";
      #      sha256 = "1h768ljlh3pi23l27qp961v1hd0nbj2vasgy11bmcrlqp40zgvnr";
      #    })
      #  ];
      profiles = {
        "${config.home.username}" = {
          isDefault = true;

          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            darkreader
            ublock-origin
            bitwarden
            #decentraleyes
            localcdn #fork of decentraleyes
            i-dont-care-about-cookies
            ipfs-companion
            #back-to-close-we
            #detect-cloudflare-plus # True Sight - track what content delievery networks are serving you
            simple-tab-groups
            smart-referer
            sponsorblock
            #snowflake
            #old-reddit-redirect
            #reddit-enhancement-suite
            #ff2mpv
            #link-cleaner
            #markdownload
            #ipfs-companion
            #javascript-restrictor
          ];

          #search.engines = {
          #  "Nix Packages" = {
          #    urls = [{
          #      template = "https://search.nixos.org/packages";
          #      params = [
          #        { name = "type"; value = "packages"; }
          #        { name = "query"; value = "{searchTerms}"; }
          #      ];
          #    }];

          #    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          #    definedAliases = [ "@np" ];
          #  };
          #  "Nixos Options" = {
          #    urls = [{
          #      template = "https://search.nixos.org/options";
          #      params = [
          #        { name = "type"; value = "packages"; }
          #        { name = "query"; value = "{searchTerms}"; }
          #      ];
          #    }];

          #    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          #    definedAliases = [ "@np" ];
          #  };

          #  "NixOS Wiki" = {
          #    urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
          #    iconUpdateURL = "https://nixos.wiki/favicon.png";
          #    updateInterval = 24 * 60 * 60 * 1000; # every day
          #    definedAliases = [ "@nw" ];
          #  };

          #  "Bing".metaData.hidden = true;
          #  "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          #  "Amazon".metaData.alias = "@a";
          #};

          settings = {
            "browser.startup.blankWindow" = true;
            "browser.startup.page" = 3; # Startup - Open previous windows and tabs
            "browser.disableResetPrompt" = true;
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
            "browser.tabs.firefox-view" = false; # Disable Firefox View

            # Disable some not so useful functionality.
            "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;
            "extensions.htmlaboutaddons.discover.enabled" = false;
            "extensions.pocket.enabled" = false;
            "app.normandy.enabled" = false;
            "app.normandy.api_url" = "";
            "extensions.shield-recipe-client.enabled" = false;
            "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
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

            # Use screen share indicator that works better in Wayland
            "privacy.webrtc.legacyGlobalIndicator" = false;

            # causing issues to to it eliminating timezones. can't make exceptions
            # per site. will explore a profile per task in the future.
            #"privacy.resistFingerprinting" = true;
            "spellchecker.dictionary" = "en-US";
            "intl.locale.requested" = "en-US";
            "intl.regional_prefs.use_os_locales" = true;
            "browser.sessionstore.warnOnQuit" = true;
            "browser.uiCustomization.state" = ''
              {"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["_ddc62400-f22d-4dd3-8b4a-05837de53c2e_-browser-action","sponsorblocker_ajay_app-browser-action","_1c5e4c6f-5530-49a3-b216-31ce7d744db0_-browser-action","_b11bea1f-a888-4332-8d8a-cec2be7d24b9_-browser-action","gdpr_cavi_au_dk-browser-action","_04188724-64d3-497b-a4fd-7caffe6eab29_-browser-action","_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action","smart-referer_meh_paranoid_pk-browser-action","_348c6313-cb8a-456d-bc65-f9f2ccf57c29_-browser-action","_529b261b-df0b-4e3b-bf42-07b462da0ee8_-browser-action","_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action","webextension_metamask_io-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","firefox-translations-addon_mozilla_org-browser-action","_auto-reader-view-browser-action","atbc_easonwong-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","vertical-spacer","customizableui-special-spring1","urlbar-container","customizableui-special-spring2","_testpilot-containers-browser-action","downloads-button","fxa-toolbar-menu-button","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","addon_darkreader_org-browser-action","_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action","ublock0_raymondhill_net-browser-action","jid1-kkzogwgsw3ao4q_jetpack-browser-action","simple-tab-groups_drive4ik-browser-action","ipfs-firefox-addon_lidel_org-browser-action","unified-extensions-button","reset-pbm-toolbar-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["firefox-view-button","tabbrowser-tabs","new-tab-button","alltabs-button"],"vertical-tabs":[],"PersonalToolbar":["personal-bookmarks"]},"seen":["developer-button","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","addon_darkreader_org-browser-action","_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action","_b11bea1f-a888-4332-8d8a-cec2be7d24b9_-browser-action","sponsorblocker_ajay_app-browser-action","ublock0_raymondhill_net-browser-action","jid1-kkzogwgsw3ao4q_jetpack-browser-action","_1c5e4c6f-5530-49a3-b216-31ce7d744db0_-browser-action","gdpr_cavi_au_dk-browser-action","_04188724-64d3-497b-a4fd-7caffe6eab29_-browser-action","_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action","_testpilot-containers-browser-action","smart-referer_meh_paranoid_pk-browser-action","ipfs-firefox-addon_lidel_org-browser-action","_348c6313-cb8a-456d-bc65-f9f2ccf57c29_-browser-action","_529b261b-df0b-4e3b-bf42-07b462da0ee8_-browser-action","_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action","simple-tab-groups_drive4ik-browser-action","webextension_metamask_io-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","firefox-translations-addon_mozilla_org-browser-action","_auto-reader-view-browser-action","atbc_easonwong-browser-action","_ddc62400-f22d-4dd3-8b4a-05837de53c2e_-browser-action","screenshot-button"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list","unified-extensions-area","vertical-tabs"],"currentVersion":23,"newElementCount":5}
            '';
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
  };
}
