FROM alpine:3.12 as build

# Install git
RUN apk add --no-cache git && \
  # Checkout the dump1090 code
  git clone --depth 1 -b v7.1 https://github.com/flightaware/dump1090.git /tmp/dump1090 && \
  cd /tmp/dump1090 || exit

FROM alpine:3.12

# Copy the webpage and configs from the dump1090 source
COPY --from=build /tmp/dump1090/debian/lighttpd /etc/lighttpd/conf-enabled
COPY --from=build /tmp/dump1090/public_html /usr/share/dump1090-fa/html

# Install lighttpd and fix home dir permissions
RUN apk add --no-cache lighttpd && \
  mkdir -p /home/lighttpd && \
  chown -R lighttpd: /home/lighttpd

# Copy the config file into /etc/
COPY ./lighttpd.conf /etc/lighttpd/lighttpd.conf
# Copy wrapper script (to make access logs show at stderr)
COPY ./start.sh /home/lighttpd/start.sh

# Change user and directory
WORKDIR /home/lighttpd
USER lighttpd

# Run the wrapper script on startup
ENTRYPOINT [ "/bin/ash", "/home/lighttpd/start.sh" ]
