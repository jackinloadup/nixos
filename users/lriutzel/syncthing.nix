{ ... }:

let
  # .stignore at root of folder
  ignore = ''
    .git
    /node_modules
    /dist
  '';
in {
  services.syncthing.folder = {
    "/persist/home/lriutzel/Documents" = {
      id = "lriutzel-documents";
      label = "LRiutzel Documents";
      devices = [ "bigbox" ];
    };
    "/persist/home/lriutzel/Projects" = {
      id = "lriutzel-projects";
      label = "LRiutzel Projects";
      devices = [ "bigbox" ];
    };
    # manuals
    # reciepts/paperless
    # music
    # pictures / wallpapers
    # 
  };
}
