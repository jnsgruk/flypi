FROM alpine:3.12
# Install gpsd
RUN apk add --no-cache gpsd
# Start gpsd, point it at the USB GPS receiver, make sure it doesn't go to background
ENTRYPOINT [ "/usr/sbin/gpsd", "-G", "-N", "/dev/ttyUSB0"]
