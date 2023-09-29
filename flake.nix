{
  description = "flypi flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nix-formatter-pack
    , ...
    }:
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsForSystem = system: (import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });
    in
    {
      overlay = final: prev: {
        dump1090-fa = prev.dump1090.overrideAttrs (oldAttrs: rec {
          buildFlags = oldAttrs.buildFlags ++ [ "faup1090" ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin $out/share $out/etc/default
            cp -v dump1090 $out/bin/dump1090-fa
            cp -v view1090 faup1090 $out/bin
            cp -vr public_html $out/share/dump1090

            substituteInPlace debian/start-dump1090-fa \
              --replace "/etc/default/dump1090-fa" "$out/etc/default/dump1090-fa" \
              --replace "/usr/bin/dump1090-fa" "$out/bin/dump1090-fa"

            install -m 0755 -D debian/start-dump1090-fa $out/bin/start-dump1090-fa
            install -m 0644 -D debian/dump1090-fa.default $out/etc/default/dump1090-fa

            runHook postInstall
          '';
        });

        fr24 = final.callPackage ./pkgs/fr24 { };
        piaware = final.callPackage ./pkgs/piaware { };
        planefinder = final.callPackage ./pkgs/planefinder { };
        realadsb = final.callPackage ./pkgs/realadsb { };
        tcllauncher = final.callPackage ./pkgs/tcllauncher { };
      };

      packages = forAllSystems
        (system: {
          inherit (pkgsForSystem system)
            dump1090
            fr24
            piaware
            planefinder
            realadsb
            tcllauncher;
        });

      nixosModules = {
        dump1090 = import ./modules/dump1090.nix;
        fr24 = import ./modules/fr24.nix;
        piaware = import ./modules/piaware.nix;
        planefinder = import ./modules/planefinder.nix;
        realadsb = import ./modules/realadsb.nix;
      };

      formatter = forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );
    };
}
