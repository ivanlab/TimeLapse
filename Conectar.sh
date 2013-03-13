#!/bin/bash

# Silencia la salida por pantalla (NO FUNCIONA!!!)
# set +v

##########
# DOCS. #
#########

# Script to monitor and restart wireless access point when needed
#  El script:
# 	- Permite definir cuantas interfaces, o más bien  cuales, tiene disponibles
# 	- En funcion de las interfaces hay preferencias (eth0, wlan0, wwan0)
# 	- Cada 5 mins comprueba que tiene  acceso a internet

# Necesita para funcionar la aplicación Sakis3g, que se puede descarga de:
# http://www.sakis3g.org


################
# PARAMETROS #
###############

# Funcion LOG
LOG_FILE=./logs # Fichero Logs (Verificar que tiene permisos!!)

# Funcion SEND_MAIL
MAIL_TEMP_TEXT=./`date "+%Y%m%d"_"%H%M%S"`_MAIL # Filename temporal para cuerpo mail
DST_MAIL=personajeje@gmail.com                  # e-mail destino de alertas

maxPloss=10     # Maximum percent packet loss before a restart

##############
# FUNCIONES #
#############

# Función LOG
# Imprime mensajes en fichero de log
# Sintaxis:	LOG "Texto que se quiere sacar por fichero logs"

function LOG(){
 echo `date "+%Y%m%d"_"%H%M%S"` - $1 >>  $LOG_FILE
}

# Función CREAR_CARPETA
# Comprueba si existe la carpeta y, en caso negativo, la crea.
# Sintaxis:	CREAR_CARPETA FOLDER_PATH
function CREAR_CARPETA(){
 FOLDER_PATH=$1
 if [[ ! -d $FOLDER_PATH ]]
 then
     mkdir $FOLDER_PATH
     log "Creada carpeta: $FOLDER_PATH" 
 fi
}

# Función SEND_MAIL
# Envía mensajes por correo.
# Sintaxis:	SEND_MAIL "EMAIL" "SUBJECT" "MESSAGE_TXT_FILE"

function SEND_MAIL (){
 EMAIL=$1
 SUBJECT=$2
 MESSAGE_TXT_FILE=$3

 mail -s $SUBJECT $EMAIL < $MESSAGE_TXT_FILE
 log "Correo enviado a $EMAIL con asunto $SUBJECT"
}

# Función REINICIAR_INTERFAZ
# Reinicia la interfaz indicada.
# No sirve para interfaz wwan (Modem 3G)
# Sintaxis:	REINICIAR_INTERFAZ interfaz

function REINICIAR_WLAN() {
 INTERFAZ=$1

 ifdown INTERFAZ && ifup INTERFAZ
}

# Función REINICIAR_WWAN
# Reinicia la interfaz 3G
#

# REINICIAR_WWAN() {
# CONECTADO="./sakis3g connected"
# echo "RV-previo: $?"
# echo $CONECTADO
#  if  ! $CONECTADO
#   then
# 	echo "RV-Dentro-IF: $?"
#     echo "Conectado"
# #    ./sakis3g USBINTERFACE="4" APN="movistar.es" SIM_PIN="4334" connect
#  else
#  	echo "RV-else: $?"
#  	echo "Desconectado"
# fi
# }


REINICIAR_WWAN() {
DESCONECTADO="./sakis3g disconnected"
 if  $DESCONECTADO
  then
  	# Si desconectado, vuelve a lanzar la conexión.
  	./sakis3g USBINTERFACE="4" APN="movistar.es" SIM_PIN="4334" connect
 else
 	echo "RV-else: $?"
 	echo "Desconectado"
fi
}


###########
# CUERPO #
##########
REINICIAR_WWAN
exit 0





