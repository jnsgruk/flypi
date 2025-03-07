{ pkgs, lib, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "realadsb";
  version = "3";

  src = pkgs.fetchurl {
    url = "http://www.realadsb.com/dl/adsb_hub3.jar";
    hash = "sha256-HHyolGrIan2YFsLfYIuZkMeMWeYqGCQRCSQnra2X9PI=";
    # Server returns HTTP 406 with standard user agent 🤷‍♂️
    curlOpts = "--user-agent Foobar";
  };

  # Don't unpack the source; it's just a direct link to a JAR file
  dontUnpack = true;

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -pv $out/share/java $out/bin
    cp ${src} $out/share/java/${pname}-${version}.jar

    makeWrapper ${pkgs.jre}/bin/java $out/bin/realadsb \
      --add-flags "-jar $out/share/java/${pname}-${version}.jar"

    runHook postInstall
  '';

  meta = {
    description = "Track airplanes in comfort of your home";
    homepage = "http://realadsb.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ jnsgruk ];
    mainProgram = "realadsb";
  };

}
