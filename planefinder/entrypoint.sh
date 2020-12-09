#!/bin/bash

cat <<-EOF > /home/planefinder/config.json
{
  "tcp_address": "dump1090",
  "tcp_port": "30005",
  "select_timeout": "10",
  "data_upload_interval": "10",
  "connection_type": "1",
  "aircraft_timeout": "30",
  "data_format": "1",
  "latitude": "$LAT",
  "longitude": "$LON",
  "sharecode": "$PLANEFINDER_SHARECODE"
}
EOF

/usr/local/bin/pfclient --config_path=/home/planefinder/config.json