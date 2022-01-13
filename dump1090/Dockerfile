FROM alpine:3.12 AS build

RUN apk add --no-cache libusb ncurses git build-base libusb-dev ncurses-dev librtlsdr librtlsdr-dev && \
  # Get the dump1090 repository
  git clone --depth 1 -b v7.1 https://github.com/flightaware/dump1090.git /tmp/dump1090 && \
  cd /tmp/dump1090 && \
  # Build dump1090 and install
  make dump1090 DUMP1090_VERSION=v7.1 BLADERF=no RTLSDR=yes LIMESDR=no HACKRF=no && \
  install -m 0755 -D dump1090 /usr/bin/dump1090-fa && \
  # Build view1090 and install
  make view1090 DUMP1090_VERSION=v7.1  BLADERF=no RTLSDR=yes LIMESDR=no HACKRF=no && \
  install -m 0755 -D view1090 /usr/bin/view1090 && \
  # Build faup1090 and install
  make faup1090 DUMP1090_VERSION=v7.1  BLADERF=no RTLSDR=yes LIMESDR=no HACKRF=no && \
  install -m 0755 -D faup1090 /usr/bin/faup1090 && \
  # Install the start script and default config
  install -m 0755 -D debian/start-dump1090-fa /usr/share/dump1090-fa/start-dump1090-fa && \
  install -m 0644 -D debian/dump1090-fa.default /etc/default/dump1090-fa && \
  # Clean up
  rm -rf /tmp/* && \
  apk del git build-base librtlsdr-dev libusb-dev ncurses-dev && \
  # Blacklist unwanted drivers
  echo "blacklist dvb_usb_rtl28xxu" > /etc/modprobe.d/raspi-blacklist.conf && \
  # Create the missing plugdev group
  addgroup --gid 46 plugdev && \
  # Create a non-priv user and setup home directory
  adduser -D -G plugdev dump1090

# Add the entrypoint script
COPY entrypoint.sh /home/dump1090/entrypoint.sh
# Create the dump directory and fix home directory permissions
RUN mkdir -p /home/dump1090/json && \
  chown -R dump1090: /home/dump1090 

# Switch user and directory
USER dump1090
WORKDIR /home/dump1090


ENTRYPOINT ["/bin/ash", "/home/dump1090/entrypoint.sh"]