{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.realadsb;
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "realadsb.json" cfg.settings;
in
{
  options = {
    services.realadsb = {
      enable = lib.mkEnableOption (lib.mdDoc "the RealADSB client");

      package = lib.mkPackageOptionMD pkgs "realadsb" { };

      settings = {
        input = types.listOf {
          type = lib.mkOption {
            type = lib.types.enum [ "beast_tcp" ];
            default = "beast_tcp";
            description = lib.mdDoc "The input type for RealADSB to use.";
          };
          name = lib.mkOption {
            type = lib.types.str;
            default = "dump1090";
            description = lib.mdDoc "The name of the input.";
          };
          host = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = lib.mdDoc "The host or IP where the input source is located.";
          };
          port = lib.mkOption {
            type = lib.types.int;
            default = 30005;
            description = lib.mdDoc "The port serving the input source.";
          };
        };

        output = types.listOf {
          type = lib.mkOption {
            type = lib.types.enum [ "lametric" ];
            default = "lametric";
            description = lib.mdDoc "The output type for RealADSB to use.";
          };
          name = lib.mkOption {
            type = lib.types.str;
            default = "lametric";
            description = lib.mdDoc "The name of the output";
          };
          host = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = lib.mdDoc "The host or IP where the output sink is located.";
          };
          token = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = lib.mdDoc "The access token for the output if required";
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
    };

    config = lib.mkIf cfg.enable {
      systemd.services.realadsb = {
        description = "realadsb";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          Restart = "on-failure";
          ExecStart = "${lib.getExe cfg.package} ${configFile}";
        };
      };
    };
  };
}
