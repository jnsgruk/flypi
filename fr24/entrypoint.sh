#!/bin/bash

FR24KEY="${FR24KEY:-}"
# Check if a key is specified 
if [[ -z "${FR24KEY}" ]]; then
  echo 2>&1 "Please specify FR24KEY environment variable."
  exit 1
else
  # Start fr24feed
  /usr/bin/fr24feed --config-file=/home/fr24/fr24feed.ini --fr24key="${FR24KEY}"
fi