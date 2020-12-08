#!/bin/ash

# Output access logs for lighttpd to stdout
exec 3>&1
lighttpd -D -f /etc/lighttpd/lighttpd.conf