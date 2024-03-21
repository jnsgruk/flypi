{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dump1090;
in
{
  options = {
    services.dump1090 = {
      enable = lib.mkEnableOption (lib.mdDoc "A simple Mode S decoder for RTLSDR devices");

      package = lib.mkPackageOptionMD pkgs "dump1090-fa" { };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for fr24.";
      };

      ui = {
        enable = lib.mkEnableOption (lib.mdDoc "Enable dump1090 web ui");

        port = lib.mkOption {
          type = lib.types.int;
          default = 8080;
          description = lib.mdDoc "Port for web ui for listen on";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 30005 ];
    };

    hardware.rtl-sdr.enable = true;

    systemd.services.dump1090 = {
      description = "dump1090";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        Group = "plugdev";
        RuntimeDirectory = "dump1090-fa";
        ExecStart = "${cfg.package}/bin/start-dump1090-fa --write-json /run/dump1090-fa --write-json-every 1 --quiet";
        Restart = "on-failure";
      };
    };

    services.lighttpd = mkIf cfg.ui.enable {
      enable = true;
      inherit (cfg.ui) port;
      document-root = "${cfg.package}/share/dump1090";
      enableUpstreamMimeTypes = true;
      enableModules = [
        "mod_access"
        "mod_accesslog"
        "mod_alias"
        "mod_compress"
        "mod_redirect"
        "mod_setenv"
      ];
      extraConfig = ''
        server.stat-cache-engine = "disable"

        alias.url += (
          "/dump1090-fa/data/" => "/run/dump1090-fa/",
          "/dump1090-fa/" => "${cfg.package}/share/dump1090",
          "/data/receiver.json" => "/run/dump1090-fa/receiver.json",
          "/status.json" => "/run/dump1090-fa/stats.json",
          "/data/" => "/run/dump1090-fa/",
        )

        url.redirect += (
          "^/dump1090-fa$" => "/dump1090-fa/"
        )

        $HTTP["url"] =~ "^/dump1090-fa/data/.*\.json$" {
          setenv.set-response-header = ( "Access-Control-Allow-Origin" => "*" )
        }
      '';
    };
  };
}
