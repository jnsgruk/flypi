FROM debian:buster-slim AS build

ENV DEBIAN_FRONTEND=noninteractive

# Set the FlightRadar24 version to fetch
# WARNING: The 1.0.26 builds seem to have issues on Rpi
ENV FR24_VERSION 1.0.25-3
WORKDIR /tmp 
RUN apt-get update && \
  # Download some utilities
  apt-get install -y --no-install-recommends wget ca-certificates tar && \
  # Get the FR24 binaries
  wget -qO fr24feed.tgz "https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_${FR24_VERSION}_armhf.tgz" && \
  # Extract the archive
  tar xvzf fr24feed.tgz && \
  # Clean up apt lists
  apt-get clean &&  \
  rm -rf /var/lib/apt/lists/*

# Start new container
FROM debian:buster-slim

# Copy across the fr24feed binary and SSL certificates
COPY --from=build /tmp/fr24feed_armhf/fr24feed /usr/bin/fr24feed
COPY --from=build /etc/ssl /etc/ssl
# Copy the custom config file and entrypoint
COPY fr24feed.ini /home/fr24/fr24feed.ini
COPY entrypoint.sh /home/fr24/entrypoint.sh

# Add a user and set permissions
RUN useradd -s /bin/bash fr24 && mkdir -p /home/fr24/log && chown -R fr24:fr24 /home/fr24

# Change user and woring directory
USER fr24
WORKDIR /home/fr24

# Set the entrypoint for the container
ENTRYPOINT [ "/bin/bash", "/home/fr24/entrypoint.sh" ]