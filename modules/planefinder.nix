{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.planefinder;

  mkConfigFile =
    cfg:
    if cfg.configFile == null then
      pkgs.writeTextFile {
        name = "planefinder-config.json";
        text = ''
          {
            "tcp_address": "localhost",
            "tcp_port": "30005",
            "select_timeout": "10",
            "data_upload_interval": "10",
            "connection_type": "1",
            "aircraft_timeout": "30",
            "data_format": "1",
            "sharecode": "${cfg.shareCode}",
            "latitude": "${cfg.latitude}",
            "longitude": "${cfg.longitude}"
          }
        '';
      }
    else
      cfg.configFile;
in
{
  options = {
    services.planefinder = {
      enable = lib.mkEnableOption (lib.mdDoc "the Planefinder client");

      package = lib.mkPackageOptionMD pkgs "planefinder" { };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for planefinder.";
      };

      configFile = lib.mkOption {
        default = null;
        description = ''
          Path to Planefinder config file.

          Setting this option will override any configuration applied by
          other configuration options.
        '';
        type = lib.types.nullOr lib.types.path;
      };

      shareCode = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = lib.mdDoc "Your Planefinder share code";
      };

      latitude = lib.mkOption {
        type = lib.types.str;
        default = "0.0";
        description = lib.mdDoc "Latitude of reciever";
      };

      longitude = lib.mkOption {
        type = lib.types.str;
        default = "0.0";
        description = lib.mdDoc "Longitude of reciever";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ 30053 ]; };

    systemd.services.planefinder = {
      description = "planefinder";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        Restart = "on-failure";
        ExecStart = "${lib.getExe cfg.package} --config_path=${mkConfigFile cfg}";
      };
    };
  };
}
