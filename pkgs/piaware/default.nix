{ pkgs
, lib
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "piaware";
  version = "8.2";

  src = pkgs.fetchFromGitHub {
    owner = "flightaware";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-La0J+6Y0cWr6fTr0ppzYV6Vq00GisyDxmSyGzR7nfpg=";
  };

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  buildInputs = with pkgs; [
    tcl
    tcllauncher
    openssl
    which
  ];

  patches = [ ./paths.patch ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    wrapProgram $out/bin/piaware \
      --set TCLLIBPATH "${pkgs.tcltls}/lib ${pkgs.tcllib}/lib" \
      --prefix PATH : "${lib.makeBinPath [pkgs.iproute2 pkgs.coreutils pkgs.systemd pkgs.tcllauncher pkgs.nettools pkgs.dump1090-fa]}"
  '';

  meta = {
    description = "Client-side package and programs for forwarding ADS-B data to FlightAware";
    homepage = "https://github.com/flightaware/piaware";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ jnsgruk ];
  };
}
