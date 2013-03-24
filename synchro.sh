#!/bin/sh

#  synchro.sh
#  TimeLapse
#
#  Created by Ivan Padilla Ojeda on 2013.03.24.
#
NASUSER=ivan
NASHOST=nas.ivanlab.org
NASPATH=/media/NAS/00_Raspbian_Sync/
LPATH=/home/pi/TimeLapse/Fotos

rsync -az -e "ssh -p 7998" $LPATH $NASUSER@$NASHOST:$NASPATH
