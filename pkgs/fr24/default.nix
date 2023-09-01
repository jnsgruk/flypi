{ pkgs
, lib
, ...
}:
let
  # Versions from https://www.flightradar24.com/share-your-data#linux
  version = "1.0.34-0";

  sources = {
    x86_64-linux = {
      url = "https://repo-feed.flightradar24.com/linux_x86_64_binaries/fr24feed_${version}_amd64.tgz";
      hash = "sha256-baXxzua3EDqzXAAWAikynTHOW3XxGchTHtIoWS2xXWc=";
    };
    aarch64-linux = {
      url = "https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_${version}_armhf.tgz";
      hash = "sha256-LM1kghAUB36QV09Dx8Ona/J6axKxapqxUWx9pPgScsY=";
    };
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "fr24";
  inherit version;

  src = pkgs.fetchurl {
    inherit (sources.${pkgs.system}) url hash;
  };

  fhsEnv = pkgs.buildFHSEnv {
    name = "${pname}-fhs-env";
    runScript = "";
    targetPkgs = pkgs: with pkgs; [
      dump1090
      procps
      nettools
      bashInteractive
    ];
  };

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm 0755 fr24feed $out/bin/fr24feed

    makeWrapper ${fhsEnv}/bin/${pname}-fhs-env $out/bin/fr24 \
      --add-flags $out/bin/fr24feed \
      --argv0 fr24feed
    runHook postInstall
  '';

  meta = {
    description = "Client for sharing data received over ADS-B with Flightradar24";
    homepage = "https://www.flightradar24.com/share-your-data";
    license = lib.licenses.unfree;
    mainProgram = "fr24";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ jnsgruk ];
  };

}

