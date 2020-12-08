#!/bin/ash

# Configure a feeder-id if the FEEDER_ID env var is setSSSS
if [[ -n "${FEEDER_ID:-}" ]]; then
  piaware-config -configfile /home/piaware/.piaware/piaware.conf feeder-id "${FEEDER_ID}"
fi

# Disable gpsd if specified in the environment
if [[ "${USE_GPSD}" == "no" ]]; then
  piaware-config -configfile /home/piaware/.piaware/piaware.conf use-gpsd no
fi

# Start piaware
/usr/bin/piaware \
  -plainlog \
  -p /home/piaware/.piaware/piaware.pid \
  -statusfile /home/piaware/.piaware/status.json \
  -cachedir /home/piaware/.piaware/cache \
  -configfile /home/piaware/.piaware/piaware.conf