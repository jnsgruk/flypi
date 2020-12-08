FROM alpine:3.12

# Add some build dependencies
RUN apk add --no-cache libusb ncurses git build-base libusb-dev ncurses-dev \
        tcl-dev tcl tclx tcl-tls autoconf net-tools iproute2 && \
        # Clone the tcllauncher project
        git clone --depth 1 -b v1.8 https://github.com/flightaware/tcllauncher /tmp/tcllauncher && \
        cd /tmp/tcllauncher && \
        # Configure, build and install
        autoconf -f && \
        ./configure && \
        make && \
        make install && \
        # Get the tcllib repository to make tcllauncher work properly
        git clone --depth 1 -b tcllib_1_18 https://github.com/tcltk/tcllib /tmp/tcllib && \
        cd /tmp/tcllib && \
        # Configure, build and install tcllib
        autoconf && \
        ./configure && \
        make && make install && \
        # Get the Piaware Code
        git clone --depth 1 -b v4.0 https://github.com/flightaware/piaware.git /tmp/piaware && \
        cd /tmp/piaware && \
	# Patch Piaware source code so it doesn't rely upon localhost for gpsd
	sed -i 's/"localhost"/"gpsd"/g' package/fa_gps.tcl && \
        # Build and install Piaware
        make install && \
        # Get the dump1090 repository
        git clone --depth 1 -b v4.0 https://github.com/flightaware/dump1090.git /tmp/dump1090 && \
        cd /tmp/dump1090 && \
        # Build faup1090, ingore radio support as its handled by another container
        make faup1090 BLADERF=no RTLSDR=no LIMESDR=no HACKRF=no && \
        cp -a faup1090 /usr/lib/piaware/helpers && \
        # Clean up build dependencies
        rm -rf /tmp/* && \
        apk del git build-base libusb-dev ncurses-dev tcl-dev autoconf && \
        # Add a non-priv user for Piaware
        adduser -D piaware

# Copy example config into container
COPY piaware.conf /home/piaware/.piaware/piaware.conf
COPY entrypoint.sh /home/piaware/.piaware/entrypoint.sh
# Fix permissions on Piaware user home directory
RUN chown -R piaware:piaware /home/piaware
# Switch user and directory
USER piaware
WORKDIR /home/piaware

# Run Piaware with some custom options
ENTRYPOINT ["/bin/ash", "/home/piaware/.piaware/entrypoint.sh"]
