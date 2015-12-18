#!/bin/sh

#  synchro.sh
#  TimeLapse
#
#  Created by Ivan Padilla Ojeda on 2013.03.24.
#
# Parametros rsync

NASUSER=huri
NASHOST=173.39.245.44
NASPATH=/var/www/html/owncloud/data/timelapse/files/Photos/Timelapse/Fotos_JPG/
LPATH=/media/tera/Fotos_JPG/

# Función LOG
LOG_PATH=/media/tera/Logs            # (Verificar que tiene permisos!!) .NO AÑADIR BARRA FINAL!!!
LOG_FILE=TimeLapse_`date "+%Y%m%d"`.log     # Fichero Logs (Verificar que tiene permisos!!)
LOG_FILE=$LOG_PATH/$LOG_FILE

# Función LOG
# Imprime mensajes en fichero de log
# Sintaxis:	log "Texto que se quiere sacar por fichero logs"

# function log() 
# {
#  if [[ ! -f $LOG_FILE ]]
#  then
#     crear_carpeta $LOG_PATH
#     touch $LOG_FILE
#     echo `date "+%Y%m%d"_"%H%M%S"` - $1 >>  $LOG_FILE
#  else
#     echo `date "+%Y%m%d"_"%H%M%S"` - $1 >>  $LOG_FILE
#  fi
# }
# Función CREAR_CARPETA
# Comprueba si existe la carpeta y, en caso negativo, la crea.
# Sintaxis:	crear_carpeta FOLDER_PATH

# function crear_carpeta()
# {
#  FOLDER_PATH=$1
#  if [[ ! -d $FOLDER_PATH ]]
#  then
#     mkdir -p $FOLDER_PATH
#  fi
# }

# CUERPO
if ! ping -c 3 8.8.8.8
	then
	 	ifdown wlan0 && ifup wlan0
	else
	    if [ ! -f /tmp/rsync.lock ]
			then
			    touch /tmp/rsync.lock
			    # log "Sin restriccion previa rsync.lock -> Iniciando syncronizacion"
			    
			    if ! rsync -vz -e "ssh -p 6666 -i /home/pi/.ssh/id_rsa" $LPATH $NASUSER@$NASHOST:$NASPATH
			    	then 
			    		# log "error en sincronizacion"
			    		echo error
			    	else
			    		# log "sincronizacion realizada con exito"
			    		echo success
			    fi
			    rm /tmp/rsync.lock
			else echo "rsync is locked by /tmp/rsync.lock"
		fi
 fi



