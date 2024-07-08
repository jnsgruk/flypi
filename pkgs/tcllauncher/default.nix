{ pkgs, lib, ... }:
let
  pname = "tcllauncher";
  version = "1.10";
in
pkgs.tcl.mkTclDerivation {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "flightaware";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-BVrsoczKeBBoM1Q3v6EJY81QwsX6xbUqFkcBb482WH4=";
  };

  nativeBuildInputs = with pkgs; [ autoreconfHook ];

  buildInputs = with pkgs; [ tclx ];

  patches = [ ./wrapped.patch ];

  meta = {
    description = "A launcher program for Tcl applications";
    homepage = "https://github.com/flightaware/tcllauncher";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ jnsgruk ];
  };

}
