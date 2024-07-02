{ pkgs
, lib
, ...
}:
let
  # Versions from https://planefinder.net/coverage/client
  sources = {
    x86_64-linux = rec {
      version = "5.0.162";
      url = "http://client.planefinder.net/pfclient_${version}_amd64.tar.gz";
      hash = "sha256-t8Nanu0qxbW1mmSOYJKDAt8RJzmzwym0J+BtTEWHuwc=";
    };
    aarch64-linux = rec {
      version = "5.1.440";
      url = "http://client.planefinder.net/pfclient_${version}_arm64.tar.gz";
      hash = "sha256-ozV1J3AZ0OKqUotDXAqV9v/v0xE94PqpVo6rzk4HXH8=";
    };
  };
in
pkgs.stdenv.mkDerivation {
  pname = "planefinder";
  inherit (sources.${pkgs.system}) version;

  src = pkgs.fetchurl {
    inherit (sources.${pkgs.system}) url hash;
  };

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";

  installPhase = ''
    install -Dm 0755 pfclient $out/bin/pfclient
  '';

  postFixup = ''
    patchelf --set-interpreter ${pkgs.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 $out/bin/pfclient
  '';

  meta = {
    description = "Client for sharing data received over ADS-B with Planefinder";
    homepage = "https://planefinder.net/coverage/client";
    mainProgram = "pfclient";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ jnsgruk ];
  };

}

