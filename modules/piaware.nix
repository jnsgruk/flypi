{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.piaware;

  mkConfigFile =
    cfg:
    pkgs.writeTextFile {
      name = "piaware.conf";
      text = ''
        receiver-host "localhost"
        receiver-type "other"
        feeder-id     "${cfg.feederId}"
      '';
    };
in
{
  options = {
    services.piaware = {
      enable = lib.mkEnableOption (lib.mdDoc "the Piaware client");

      package = lib.mkPackageOptionMD pkgs "piaware" { };

      feederId = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = lib.mdDoc "Your Flightaware feeder ID";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.piaware = {
      description = "piawarefeed";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        CacheDirectory = "piaware";
        RuntimeDirectory = "piaware";
        StateDirectory = "piaware";
        Restart = "on-failure";
        ExecStart = "${lib.getExe cfg.package} -plainlog -cachedir /var/cache/piaware -configfile ${mkConfigFile cfg}";
      };
    };
  };
}

# Possible config file lines:

#adept-serverhosts             "piaware.flightaware.com piaware.flightaware.com {70.42.6.156 70.42.6.232 70.42.6.224 70.42.6.228 70.42.6.198 70.42.6.225}" # using default value
#adept-serverport              1200                           # using default value
#allow-auto-updates            no                             # using default value
#allow-dhcp-duid               yes                            # using default value
#allow-manual-updates          no                             # using default value
#allow-mlat                    yes                            # using default value
#allow-modeac                  yes                            # using default value
#beast-baudrate                <unset>                        # no value set and no default value
#enable-firehose               no                             # using default value
#feeder-id                     <unset>                        # no value set and no default value
#force-macaddress              <unset>                        # no value set and no default value
#http-proxy-host               <unset>                        # no value set and no default value
#http-proxy-password           <unset>                        # no value set and no default value
#http-proxy-port               <unset>                        # no value set and no default value
#http-proxy-user               <unset>                        # no value set and no default value
#image-type                    <unset>                        # no value set and no default value
#manage-config                 no                             # using default value
#mlat-results                  yes                            # using default value
#mlat-results-anon             yes                            # using default value
#mlat-results-format           "beast,connect,localhost:30104 beast,listen,30105 ext_basestation,listen,30106" # using default value
#network-config-style          buster                         # using default value
#priority                      <unset>                        # no value set and no default value
#radarcape-host                <unset>                        # no value set and no default value
#receiver-port                 30005                          # using default value
#rfkill                        no                             # using default value
#rtlsdr-device-index           0                              # using default value
#rtlsdr-gain                   max                            # using default value
#rtlsdr-ppm                    0                              # using default value
#uat-receiver-host             <unset>                        # no value set and no default value
#uat-receiver-port             30978                          # using default value
#uat-receiver-type             none                           # using default value
#uat-sdr-device                driver=rtlsdr                  # using default value
#uat-sdr-gain                  max                            # using default value
#uat-sdr-ppm                   0                              # using default value
#use-gpsd                      no                             # using default value
#wired-address                 <unset>                        # no value set and no default value
#wired-broadcast               <unset>                        # no value set and no default value
#wired-gateway                 <unset>                        # no value set and no default value
#wired-nameservers             "8.8.8.8 8.8.4.4"              # using default value
#wired-netmask                 <unset>                        # no value set and no default value
#wired-network                 yes                            # using default value
#wired-type                    dhcp                           # using default value
#wireless-address              <unset>                        # no value set and no default value
#wireless-broadcast            <unset>                        # no value set and no default value
#wireless-country              00                             # using default value
#wireless-gateway              <unset>                        # no value set and no default value
#wireless-nameservers          "8.8.8.8 8.8.4.4"              # using default value
#wireless-netmask              <unset>                        # no value set and no default value
#wireless-network              no                             # using default value
#wireless-password             <unset>                        # no value set and no default value
#wireless-ssid                 <unset>                        # no value set and no default value
#wireless-type                 dhcp                           # using default value
