#!/bin/bash
set -euo pipefail

# Write a config file that configures RealADSB to consume dump1090
# from the dump190 container, and outputs to a LaMetric clock
# https://www.realadsb.com/configuration.html
cat <<-EOF > /home/realadsb/config.json 
{
  "input": [
    {
      "type": "beast_tcp",
      "name": "dump1090",
      "host": "dump1090",
      "port": 30005
    }
  ],
  "output": [
    {
      "type": "lametric",
      "name": "LaMetric clock",
      "host": "$LAMETRIC_IP",
      "access_token": "$LAMETRIC_ACCESS_TOKEN",
      "latitude": "$LAT",
      "longitude": "$LON"
    }
  ]
}
EOF

/usr/bin/java -jar /home/realadsb/adsb_hub3.jar /home/realadsb/config.json
