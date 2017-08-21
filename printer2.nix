{ stdenv, fetchurl, cups, dpkg, ghostscript, patchelf, a2ps, coreutils, gnused, gawk, file, makeWrapper }:

stdenv.mkDerivation rec {
  name = "mfcj47dd0dw-cupswrapper-${version}";
  version = "3.0.0-1";

  src = fetchurl {
    url = "http://download.brother.com/welcome/dlf006148/mfc5440cnlpr-1.0.2-1.i386.deb";
    sha256 = "ce1c2f3778e4101ddd114d5a6274a8b5a034807f54d68e1b74de42007a616db6";
  };

  srcLPD = ./brlpdwrapperMFC5440CN;
  srcPPD = ./MFC.ppd;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ cups ghostscript dpkg a2ps ];

  unpackPhase = "true";

  installPhase = ''
    ar x $src
    tar xzvf data.tar.gz
    substituteInPlace usr/local/Brother/lpd/filterMFC5440CN \
    --replace /opt "$out/opt"
    sed -i '/GHOST_SCRIPT=/c\GHOST_SCRIPT=gs' usr/local/Brother/lpd/psconvertij2
        patchelf --set-interpreter ${stdenv.glibc.out}/lib/ld-linux.so.2 usr/local/Brother/lpd/rastertobrij2
    #install -m 755 $srcLPD $out/lib/cups/filter/brlpdwrapperMFC5440CN
    cp $srcLPD ./brlpdwrapperMFC5440CN
    substituteInPlace brlpdwrapperMFC5440CN \
    --replace /usr "$out/usr" \
    --replace CHANGE "$out/share/cups/model/brmfc5440cn_cups.ppd"
    substituteInPlace usr/local/Brother/lpd/filterMFC5440CN \
    --replace /usr/local/Brother/ "$out/usr/local/Brother/"
    wrapProgram usr/local/Brother/lpd/psconvertij2 \
    --prefix PATH ":" ${ stdenv.lib.makeBinPath [ gnused coreutils gawk ] }
    wrapProgram usr/local/Brother/lpd/filterMFC5440CN \
    --prefix PATH ":" ${ stdenv.lib.makeBinPath [ ghostscript a2ps file gnused coreutils ] }

    mkdir -p $out
    mkdir -p $out/weg
    mkdir -p $out/lib/cups/filter/
    mkdir -p $out/share/cups/model
    cp -r -v usr $out
    cp $srcLPD $out/lib/cups/filter/brlpdwrapperMFC5440CN
    cp $srcPPD $out/share/cups/model/brmfc5440cn_cups.ppd
    '';

      postInstall = ''
    chmod 0777 $out/lib/cups/filter/brlpdwrapperMFC5440CN
      '';

  meta = {
    homepage = http://www.brother.com/;
    description = "Brother MFC-J470DW LPR driver";
    license = stdenv.lib.licenses.unfree;
    platforms = stdenv.lib.platforms.linux;
    downloadPage = http://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&prod=mfcj470dw_us_eu_as&os=128;
    maintainers = [ stdenv.lib.maintainers.yochai ];
  };
}
