#!/bin/ash

# Export the LAT/LON variables under new names if set so that 
# Piaware picks them up
if [[ -n "${LAT}" -a -n "${LAT}" ]]; then
  export PIAWARE_LAT="$LAT"
  export PIAWARE_LON="$LON"
fi

# Start Piaware using provided wrapper script
# --quiet ensures that it doesn't spam the logs!
# --writejson writes into a shared volume consumed by the lighttpd container
/usr/share/dump1090-fa/start-dump1090-fa \
  --write-json /home/dump1090/json \
  --write-json-every 1 \
  --quiet