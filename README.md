# FlyPi

A collection of tools for tracking planes/helicopters/UFOs/whatever with ADS-B. Packaged in [OCI](https://opencontainers.org/)-compliant containers and orchestrated with [`docker-compose`](https://docs.docker.com/compose/).

## Contents

Currently includes:

- [dump1090-fa](https://github.com/flightaware/dump1090)
- [piaware](https://github.com/flightaware/piaware)
- [fr24feed](https://www.flightradar24.com/share-your-data)
- [realadsb](https://www.realadsb.com/)
- [planefinder](https://planefinder.net/sharing/client)
- [gpsd](https://gpsd.gitlab.io/gpsd/)
- [lighttpd](https://www.lighttpd.net/)

## Implementation Notes

- **piaware**: patched at build time to find the `gpsd` container
- **dump1090**: built with support for rtl-sdr dongles only
- **lighttpd**: usually packaged with `dump1090`, in this implementation it runs in a separate container so it can be disabled if requred.
- **gpsd**: attaches to a USB GPS receiver at `/dev/ttyUSB0`.
- **realadsb**: preconfigured to read from dump1090 and output to a LaMetric clock. This is configurable by editing the [`entrypoint.sh`](./realadsb/entrypoint.sh) for the container

## Raspberry Pi Initial Setup

These steps have been tested on Raspbian Buster, using a [NooElec NESDR Mini2+](https://www.nooelec.com/store/nesdr-mini-2-plus.html) dongle and a [Globalsat BU-353-S4 USB GPS](https://www.globalsat.com.tw/en/product-199952/Cable-GPS-with-USB-interface-SiRF-Star-IV-BU-353S4.html) receiver.

```bash
# Install Git, and Docker/docker-compose from official repo
curl -sSL https://get.docker.com | sudo sh
sudo apt update
sudo apt install -y docker-compose git

# Blacklist the rtl drivers on the host
cat <<-EOF | sudo tee /etc/modprobe.d/rtlsdr-blacklist.conf
blacklist rtl2832
blacklist r820t
blacklist rtl2830
blacklist dvb_usb_rtl28xxu
EOF

# Install the udev rules so the correct permissions are applied to the RTL-SDR device
cat <<-EOF | sudo tee /etc/udev/rules.d/rtl-sdr.rules
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", ENV{ID_SOFTWARE_RADIO}="1", MODE:="0660", GROUP:="plugdev"
EOF

# Reload the udev rules
sudo udevadm control --reload-rules

# Clone the repo
git clone https://github.com/jnsgruk/flypi
cd flypi

# Setup an env file with your feeder id/fr24 key
cp config.env.example config.env

# Edit the example config file to include your account details
vim config.env

# Build and run the containers
sudo docker-compose up -d
```

## Browsable Endpoints

By default, the following endpoints/ports are exposed:

- Piaware: http://<pi_hostname>:8080
- Flightradar24: http://<pi_hostname>:8754
- Planefinder: http://<pi_hostname>:30053

## Contributing/TODO

Pull requests welcome, most of the heavy lifting is done in the `Dockerfile`s and `entrypoint.sh` scripts, which are all heavily commented.

Some notes on possible improvements:

- Add support for HackRF, LimeSDR, BladeRF when building `dump1090-fa`
