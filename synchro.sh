#!/bin/sh

#  synchro.sh
#  TimeLapse
#
#  Created by Ivan Padilla Ojeda on 2013.03.24.
#
# Parametros rsync
NASUSER=ivan
NASHOST=nas.ivanlab.org
NASPATH=/media/NAS/00_Raspbian_Sync/Fotos
LPATH=/mnt/tera/Fotos/jpg

# CUERPO

if [ ! -f /tmp/rsync.lock ]
then
    touch /tmp/rsync.lock
    /usr/bin/rsync -az -e "ssh -p 7998" $LPATH $NASUSER@$NASHOST:$NASPATH
    rm /tmp/rsync.lock
fi
