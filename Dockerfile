FROM local-jessie
MAINTAINER Josh Cox <josh 'at' webhosting.coop>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8

RUN apt-get -qq update; \
apt-get -qqy dist-upgrade ; \
apt-get -qqy --no-install-recommends install locales \
cmake make gcc g++ libssl-dev git curl libcurl4-openssl-dev libusb-dev wiringpi \
libudev-dev sudo procps ca-certificates wget pwgen supervisor; \
echo 'en_US.ISO-8859-15 ISO-8859-15'>>/etc/locale.gen ; \
echo 'en_US ISO-8859-1'>>/etc/locale.gen ; \
echo 'en_US.UTF-8 UTF-8'>>/etc/locale.gen ; \
locale-gen ; \
apt-get remove libboost-dev libboost-thread-dev libboost-system-dev libboost-atomic-dev libboost-regex-dev \
libboost-date-time1.55-dev libboost-date-time1.55.0 libboost-atomic1.55.0 libboost-regex1.55.0 libboost-iostreams1.55.1 \
libboost-iostreams1.55.0 libboost-iostreams1.55.0 libboost-iostreams1.55.0 \
libboost-serialization1.55-dev libboost-serialization1.55.0 libboost-system1.55-dev \
libboost-system1.55.0 libboost-thread1.55-dev libboost-thread1.55.0 libboost1.55-dev ; \
apt-get -y autoremove ; \
apt-get clean ; \
rm -Rf /var/lib/apt/lists/*

RUN mkdir /src/domoticz ; \
cd /src/domoticz ; \
wget http://www.domoticz.com/releases/release/domoticz_linux_armv7l.tgz ; \
tar xvfz domoticz_linux_armv7l.tgz ; \
rm domoticz_linux_armv7l.tgz

RUN mkdir /tmp/boost ; \
cd /tmp/boost ; \
wget http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.gz/download ; \
tar xvfz download ; \
rm download ; \
cd boost_1_60_0/ ; \
./bootstrap.sh ; \
./b2 stage threading=multi link=static --with-thread --with-date_time --with-system --with-atomic --with-regex ; \
./b2 install threading=multi link=static --with-thread --with-date_time --with-system --with-atomic --with-regex ; \
cd /tmp ; \
rm -Rf /tmp/boost

RUN cd /tmp ; \
git clone https://github.com/OpenZWave/open-zwave open-zwave-read-only ; \
cd open-zwave-read-only ; \
git pull ; \
make -j 3 ; \
cd /tmp ; \
rm -Rf open-zwave

RUN git clone https://github.com/domoticz/domoticz.git dev-domoticz ; \
cd dev-domoticz ; \
cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt ; \
make -j 3 ; \
cp domoticz.sh /etc/init.d ; \
chmod +x /etc/init.d/domoticz.sh

VOLUME /config

EXPOSE 8080

ENTRYPOINT ["/src/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log"]
CMD ["-www", "8080"]
