FROM debian:buster-slim AS build
# Stop interactive prompts in apt
ENV DEBIAN_FRONTEND noninteractive
# Change directory
WORKDIR /tmp
# Install some dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends wget tar && \
  # Download planefinder client
  wget -qO /tmp/planefinder.tar.gz http://client.planefinder.net/pfclient_4.1.1_armhf.tar.gz && \
  tar xvzf /tmp/planefinder.tar.gz

FROM debian:buster-slim
# Change directory
WORKDIR /home/planefinder
# Copy the pfclient binary from the build container
COPY --from=build /tmp/pfclient /usr/local/bin/pfclient
# Add a user
RUN useradd -s /bin/bash planefinder
# Copy the entrypoint into the container
COPY entrypoint.sh /home/planefinder/entrypoint.sh
# Fix the permissions on the home directory
RUN chown -R planefinder:planefinder /home/planefinder
# Switch user
USER planefinder
# Run planefinder, use env vars to populate the config
ENTRYPOINT ["/bin/bash", "/home/planefinder/entrypoint.sh"]
