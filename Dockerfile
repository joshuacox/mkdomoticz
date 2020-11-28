FROM debian:buster
MAINTAINER Josh Cox <josh 'at' webhosting.coop>

ENV MKDOMOTICZ_UPDATED=20201128

ARG DOMOTICZ_VERSION="master"

# install packages
RUN apt-get update && apt-get install -y \
	make gcc g++ libssl-dev git libcurl4-gnutls-dev libusb-dev python3-dev zlib1g-dev \
        libcereal-dev liblua5.3-dev uthash-dev \
	build-essential cmake \
	libboost-all-dev \
	libsqlite3-dev \
	curl \
	wget \
	libffi-dev \
	libusb-0.1-4 \
	libudev-dev \
	python3-pip \
        fail2ban && \
        apt-get remove -y --purge --auto-remove cmake

RUN apt-get update && apt-get install -y \
        liblua5.2-dev

COPY scripts /scripts

RUN bash /scripts/cmaker && \

## OpenZwave installation
# grep git version of openzwave
git clone --depth 2 https://github.com/OpenZWave/open-zwave.git /src/open-zwave && \
cd /src/open-zwave && \
# compile
make && \
make install && \

# "install" in order to be found by domoticz
#ln -s /src/open-zwave /src/open-zwave-read-only && \

## Domoticz installation
# clone git source in src
git clone --depth 2 https://github.com/domoticz/domoticz.git /src/domoticz && \
# Domoticz needs the full history to be able to calculate the version string
cd /src/domoticz && \
git fetch --unshallow && \
# prepare makefile
cmake -DCMAKE_BUILD_TYPE=Release . && \
# compile
make && \
# Install
# install -m 0555 domoticz /usr/local/bin/domoticz && \
cd /tmp && \
# Cleanup
# rm -Rf /src/domoticz && \

# ouimeaux
pip3 install -U ouimeaux && \

# remove git and tmp dirs
apt-get remove -y git cmake linux-headers-amd64 build-essential libssl-dev libboost-dev libboost-thread-dev libboost-system-dev libsqlite3-dev libcurl4-openssl-dev libusb-dev zlib1g-dev libudev-dev && \
   apt-get autoremove -y && \ 
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*


VOLUME /config

EXPOSE 8080

COPY start.sh /start.sh

#ENTRYPOINT ["/src/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log"]
#CMD ["-www", "8080"]
CMD [ "/start.sh" ]
