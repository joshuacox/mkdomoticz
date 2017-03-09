#!/bin/bash
if [ -z ${TZ+x} ]; then export TZ=America/Chicago; fi
rm /etc/localtime
cd /etc; ln -s /usr/share/zoneinfo/$TZ localtime
/src/domoticz/domoticz -dbase /config/domoticz.db -log/config/domoticz.log -www 8080
