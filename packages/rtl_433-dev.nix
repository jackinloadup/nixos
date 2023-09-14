# Needed because "Release 22.11 " isn't new enough
# nurl "https://github.com/merbanan/rtl_433" 767e5387e121b343f942f9903441794217e9fff6
{
  pkgs,
  system,
}:
pkgs.stdenv.mkDerivation {
  version = "dev";
  pname = "rtl_433";
  src = pkgs.fetchFromGitHub {
    owner = "merbanan";
    repo = "rtl_433";
    rev = "767e5387e121b343f942f9903441794217e9fff6";
    hash = "sha256-2Uis9VwcMyLTdkNCRtqNhbGGL+jNxmKuBlQ4t3kZ92s=";
  };

  nativeBuildInputs = with pkgs; [pkg-config cmake];

  buildInputs = with pkgs; [libusb1 rtl-sdr soapysdr-with-plugins];

  doCheck = true;

  meta = with pkgs.lib; {
    description = "Decode traffic from devices that broadcast on 433.9 MHz, 868 MHz, 315 MHz, 345 MHz and 915 MHz";
    homepage = "https://github.com/merbanan/rtl_433";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [earldouglas markuskowa];
    platforms = platforms.all;
    mainProgam = "rtl_433";
  };
}
