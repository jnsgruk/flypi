# FlyPi

A collection of tools for tracking planes/helicopters/UFOs/whatever with ADS-B. Packaged for NixOS.

## Contents

Currently includes:

- [dump1090-fa](https://github.com/flightaware/dump1090)
- [piaware](https://github.com/flightaware/piaware)
- [fr24feed](https://www.flightradar24.com/share-your-data)
- [realadsb](https://www.realadsb.com/)
- [planefinder](https://planefinder.net/sharing/client)

## Usage

First you must add this flake to your flake's inputs

```nix
inputs = {
    # ...
    flypi.url = "github:jnsgruk/flypi";
}
```

Ensure that you configure your system to use the included pkgs overlay:

```nix
nixpkgs = {
    overlays = [ inputs.flypi.overlay ]
};
```

Next, configure your system using the included modules:

```nix
{ inputs, ...}: {
  imports = [
    inputs.flypi.nixosModules.dump1090
    inputs.flypi.nixosModules.fr24
    inputs.flypi.nixosModules.piaware
    inputs.flypi.nixosModules.planefinder
  ];

  services = {
    dump1090 = {
      enable = true;
      ui.enable = true;
    };
    fr24 = {
      enable = true;
      sharingKey = "deadbeef";
    };
    piaware = {
      enable = true;
      feederId = "deadbeef";
    };
    planefinder = {
      enable = true;
      shareCode = "deadbeef";
      latitude = "52.352";
      longitude = "-1.621";
    };
    realadsb = {
        enable = true;
        configLines = ''
        {
          "input": [{
            "type": "beast_tcp",
            "name": "dump1090",
            "host": "localhost",
            "port": 30005
          }],
          "output": [{
            "type": "lametric",
            "name": "LaMetric clock",
            "host": "192.168.1.63",
            "access_token": "deadbeef",
            "latitude": "52.352",
            "longitude": "-1.621"
          }]
        }
      '';
    };
  };
};
```

## Browsable Endpoints

By default, the following endpoints/ports are exposed:

- Piaware: http://localhost:8080
- Flightradar24: http://localhost:8754
- Planefinder: http://localhost:30053
