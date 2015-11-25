#!/bin/sh

#  synchro.sh
#  TimeLapse
#
#  Created by Ivan Padilla Ojeda on 2013.03.24.
#
# Parametros rsync

NASUSER=huri
NASHOST=173.39.245.44
NASPATH=/var/www/html/owncloud/data/timelapse/files/Photos/Timelapse
LPATH=/media/tera/Fotos_JPG

# CUERPO
if ! ping -c 3 8.8.8.8
 then
 	ifdown wlan0 && ifup wlan0
 else
    if [ ! -f /tmp/rsync.lock ]
		then
		    touch /tmp/rsync.lock
		    /usr/bin/rsync -az -e "ssh -p 6666" $LPATH $NASUSER@$NASHOST:$NASPATH
		    echo ok
		    rm /tmp/rsync.lock
		fi
 fi



