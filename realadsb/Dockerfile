FROM debian:buster-slim
# Stop interactive prompts in apt
ENV DEBIAN_FRONTEND noninteractive

# Change directory
WORKDIR /home/realadsb

# Create this directory; Java install seems to fail without
RUN mkdir -p /usr/share/man/man1 && \
  # Install some dependencies	  
  apt-get update && \
  apt-get install -y --no-install-recommends wget default-jre-headless && \
  # Add a user
  useradd -s /bin/bash realadsb && \
  # Get the RealADSB Java application
  wget -qO realadsb.jar http://www.realadsb.com/dl/adsb_hub3.jar && \
  # Clean up apt lists
  apt-get clean &&  \
  rm -rf /var/lib/apt/lists/*

# Copy the entrypoint into the container
COPY entrypoint.sh /home/realadsb/entrypoint.sh

# Fix the permissions on the home directory
RUN chown -R realadsb:realadsb /home/realadsb
# Switch user
USER realadsb
# Run RealADSB, use env vars to populate the config
ENTRYPOINT ["/bin/bash", "/home/realadsb/entrypoint.sh"]
