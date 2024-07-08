{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.fr24;

  mkConfigFile =
    cfg:
    pkgs.writeTextFile {
      name = "fr24feed.ini";
      text = ''
        fr24key=${cfg.sharingKey}
        receiver=beast-tcp
        host=localhost:30005
        bs=no
        raw=no
        mlat=no
        mlat-without-gps=no
        bind-interface=${cfg.bindAddress}
      '';
    };
in
{
  options = {
    services.fr24 = {
      enable = lib.mkEnableOption (lib.mdDoc "the Flightradar24 client");

      package = lib.mkPackageOptionMD pkgs "fr24" { };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for fr24.";
      };

      sharingKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = lib.mdDoc "Your Flightradar24 sharing key";
      };

      bindAddress = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = lib.mdDoc "Address of the interface to bind the service to.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ 8754 ]; };

    systemd = {
      services.fr24 = {
        description = "fr24feed";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          StateDirectory = "fr24feed";
          Restart = "on-failure";
          ExecStart = "${lib.getExe cfg.package} --config-file=${mkConfigFile cfg}";
        };
      };
    };
  };
}
