#!/bin/bash
if [ -z ${TZ+x} ]; then export TZ=America/Chicago; fi
rm /etc/localtime
cd /etc; ln -s /usr/share/zoneinfo/$TZ localtime
if [ ! -z ${DOMOTICZ_OPTS+x} ]
  then
   /src/domoticz/domoticz -dbase /config/domoticz.db -log/log/domoticz.log -www 8080 -sslwww 0 $DOMOTICZ_OPTS
else
 # /usr/local/bin/domoticz -dbase /config/domoticz.db -log/log/domoticz.log -www 8080 -sslwww 0 $DOMOTICZ_OPTS
 # /src/domoticz/domoticz -dbase /config/domoticz.db -log/config/domoticz.log -www 8080 -sslwww 0 $DOMOTICZ_OPTS
   /src/domoticz/domoticz -dbase /config/domoticz.db -log /log/domoticz.log -www 8080 -sslwww 0
fi
