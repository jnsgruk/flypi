{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.realadsb;
  configFile = cfg: pkgs.writeTextFile {
    name = "realadsb.json";
    text = cfg.configLines;
  };
in
{
  options = {
    services.realadsb = {
      enable = lib.mkEnableOption (lib.mdDoc "the RealADSB client");

      package = lib.mkPackageOptionMD pkgs "realadsb" { };

      configLines = lib.mkOption {
        type = types.lines;
        default = "";
        description = lib.mdDoc "Lines for the RealADSB config file";
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
        ExecStart = "${lib.getExe cfg.package} ${configFile cfg}";
        StandardOutput = append:/var/log/realadsb.log;
        StandardError = "inherit";
      };
    };
  };
}
