{ pkgsi686Linux
, stdenv
, a2ps
, coreutils
, dpkg
, fetchurl
, file
, ghostscript
, gnugrep
, gnused
, lib
, makeWrapper
, perl
, psutils
, which
}:

let
  model = "mfc9130cw";
  humanModel = "MFC-9130CW";
  cupsVersion = "1.1.4-0";
  lprVersion = "1.1.2-1";

  reldir = "opt/brother/Printers/${model}";
  filterFile = "lpd/filter${model}";

in rec {
  driver = pkgsi686Linux.stdenv.mkDerivation rec {
    version = lprVersion;
    src = fetchurl {
      url = "https://download.brother.com/welcome/dlf100410/${model}lpr-${lprVersion}.i386.deb";
      sha256 = "6ea12c777fd19735767757e977591d8c51353ccda7b8e4af130cc48aee85736d";
    };
    name = "${model}lpr-${lprVersion}";

    nativeBuildInputs = [ dpkg makeWrapper ];

    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      dir="$out/${reldir}"
      file="$dir/${filterFile}"
      echo "Substituting $file"
      substituteInPlace "$file" \
        --replace "BR_CFG_PATH=" "BR_CFG_PATH=\"$dir\" #" \
        --replace "BR_LPD_PATH=" "BR_LPD_PATH=\"$dir\" #"

      wrapProgram "$file" \
        --prefix PATH : ${lib.makeBinPath [
          coreutils ghostscript gnugrep gnused which a2ps file psutils
        ]}

      wrapProgram "$dir/lpd/psconvertij2" \
        --prefix PATH : ${lib.makeBinPath [
          coreutils ghostscript gnugrep gnused which a2ps file psutils pkgsi686Linux.gawk
        ]}
      # need to use i686 glibc here, these are 32bit proprietary binaries
      patchelf --set-interpreter "${pkgsi686Linux.glibc}/lib/ld-linux.so.2" \
        "$dir/lpd/br${model}filter"
      patchelf --set-interpreter "${pkgsi686Linux.glibc}/lib/ld-linux.so.2" \
        "$out/usr/bin/brprintconf_${model}"
      wrapProgram "$out/usr/bin/brprintconf_${model}" --run 'cd $out'
    '';

    meta = {
      description = "Brother ${lib.strings.toUpper model} driver";
      homepage = http://www.brother.com/;
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" "i686-linux" ];
      maintainers = [ lib.maintainers.syd ];
    };
  };

  cupswrapper = stdenv.mkDerivation rec {
    version = cupsVersion;
    src = fetchurl {
      url = "https://download.brother.com/welcome/dlf100412/${model}cupswrapper-${cupsVersion}.i386.deb";
      sha256 = "4ecd12444e0eec9e9e0d15a1c37917b89a118f8e6e3685e83d8bbfe7b4bc92c1";
    };
    name = "${model}cupswrapper-${cupsVersion}";

    nativeBuildInputs = [ dpkg makeWrapper pkgsi686Linux.cups ];

    unpackPhase = "dpkg-deb -x $src $out";

    # In this package we produce two files:
    # - A ppd file
    # - A cups wrapper
    # Both of them are contained in a single file called cupswrapper${model}
    # using HEREDOCs
    # We get them out by running that file.
    # Note that we can chose the ppd filename, but the filename for the lpdwrapper comes from the contents
    # of the ppd file.
    installPhase = ''
      basedir=${driver}/${reldir}
      dir="$out/${reldir}"
      file="$dir/cupswrapper/cupswrapper${model}"
      echo "Substituting $file"
      mkdir -p "$out/share/cups/model"
      mkdir -p "$out/lib/cups/filter"

      substituteInPlace "$file" \
        --replace '/opt/brother/''${device_model}/''${printer_model}/cupswrapper/' "$dir/cupswrapper/" \
        --replace '/opt/brother/''${device_model}/''${printer_model}/lpd/' "$basedir/lpd/" \
        --replace '/opt/brother/''${device_model}/''${printer_model}/inf/' "$basedir/inf/" \
        --replace /usr/share/cups/model "$out/share/cups/model" \
        --replace /usr/share/ppd "$out/share/ppd" \
        --replace /usr/lib/cups/filter "$out/lib/cups/filter" \
        --replace /usr/lib64/cups/filter "$out/lib64/cups/filter" \
        --replace '/usr/local/Brother/''${device_model}/''${printer_model}' "$dir" \
        --replace '/usr/bin/psnup' '${psutils}/bin/psnup' \
        --replace 'tmp_filter=/var/tmp' 'tmp_filter=/tmp' \
        --replace 'lpadmin' '#' \
        --replace 'uris=' 'uris=""#'

      patchelf --set-interpreter "${pkgsi686Linux.glibc}/lib/ld-linux.so.2" \
        "$dir/cupswrapper/brcupsconfpt1"

      wrapProgram "$dir/cupswrapper/brcupsconfpt1" \
        --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused ghostscript]} \
        --prefix PATH : $driver/usr/bin

      wrapProgram "$file" \
        --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused ghostscript]}

      echo "We expect something like \"lpinfo: not found\", this can be ignored."

      $file

      lpdwrapperfile="$out/lib/cups/filter/brother_lpdwrapper_${model}"

      substituteInPlace "$lpdwrapperfile" \
        --replace '/opt/brother/Printers/mfc9130cw/inf/br${model}rc' "$basedir/inf/br${model}rc"

      wrapProgram "$lpdwrapperfile" \
        --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused psutils ghostscript ]}
    '';

    meta = {
      description = "Brother ${lib.strings.toUpper model} CUPS wrapper driver";
      homepage = http://www.brother.com/;
      license = lib.licenses.gpl2;
      platforms = [ "x86_64-linux" "i686-linux" ];
      maintainers = [ lib.maintainers.syd ];
    };
  };
}

