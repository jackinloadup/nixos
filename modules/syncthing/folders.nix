# Syncthing folder templates
# Defines folder IDs and which devices participate in each folder.
# Paths are intentionally omitted - they're specified per-machine.
#
# Usage:
#   folders = import ./folders.nix;
#   services.syncthing.settings.folders = {
#     "Documents" = folders.documents // { path = "/my/path"; };
#   };
{
  # ============================================================================
  # lriutzel folders
  # ============================================================================
  lriutzel-documents = {
    id = "lriutzel-documents";
    devices = [ "reg-system" "riko" "truenas" "riko-lriutzel" "reg-user" ];
  };

  lriutzel-projects = {
    id = "lriutzel-projects";
    devices = [ "reg-system" "riko" "truenas" "riko-lriutzel" "reg-user" ];
  };

  lriutzel-pictures = {
    id = "lriutzel-pictures";
    devices = [ "reg-system" "truenas" "riko-lriutzel" "reg-user" ];
  };

  lriutzel-mobile-camera = {
    id = "lriutzel-mobile-camera";
    devices = [ "reg-system" "pixel-6-pro" "truenas" ];
  };

  lriutzel-android-camera = {
    id = "pixel_6_pro_nfe6-photos";
    devices = [ "reg-system" "pixel-6-pro" "reg-user" ];
  };

  # ============================================================================
  # criutzel folders
  # ============================================================================
  criutzel-mobile-videos = {
    id = "christine-mobile-videos";
    devices = [ "truenas" "reg-user" "zen" "kanye-criutzel" ];
  };

  criutzel-sync = {
    id = "christine-sync";
    devices = [ "truenas" "reg-user" "jesus-criutzel" "zen" "kanye-criutzel" ];
  };

  criutzel-desktop = {
    id = "criutzel-desktop";
    devices = [ "truenas" "reg-user" "jesus-criutzel" "zen" "kanye-criutzel" ];
  };

  criutzel-documents = {
    id = "criutzel-documents";
    devices = [ "truenas" "reg-user" "jesus-criutzel" "zen" "kanye-criutzel" ];
  };

  criutzel-downloads = {
    id = "criutzel-downloads";
    devices = [ "truenas" "reg-user" "jesus-criutzel" "zen" "kanye-criutzel" ];
  };

  criutzel-music = {
    id = "criutzel-music";
    devices = [ "truenas" "reg-user" "jesus-criutzel" "zen" "kanye-criutzel" ];
  };

  criutzel-pictures = {
    id = "criutzel-pictures";
    devices = [ "truenas" "reg-user" "jesus-criutzel" "zen" "kanye-criutzel" ];
  };

  criutzel-videos = {
    id = "criutzel-videos";
    devices = [ "truenas" "zen" ];
  };

  # ============================================================================
  # Shared folders
  # ============================================================================
  shared-notification-sounds = {
    id = "shared-notification-sounds";
    devices = [ "pixel-6-pro" "kanye-criutzel" ];
  };
}
