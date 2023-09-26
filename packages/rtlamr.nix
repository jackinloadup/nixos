{
  pkgs
}:
pkgs.buildGoModule {
  pname = "rtlamr";
  version = "v0.9.1";
  vendorSha256 = null;
  src = pkgs.fetchFromGitHub {
    owner = "bemasher";
    repo = "rtlamr";
    rev = "7926ab759fcd07021dfa37d115db4fd10f2d127c";
    hash = "sha256-d22mvVcz52yeKGebsBa+a1e5JFuybF8SOA0KGLtStw8=";
  };
  meta = {
    description = "SDR receiver for Itron ERT compatible smart meters";
    homepage = "https://github.com/bemasher/rtlamr";
    longDescription = "An rtl-sdr receiver for Itron ERT compatible smart meters operating in the 900MHz ISM band";
  };
}
