#!/bin/bash

# Silencia la salida por pantalla (NO FUNCIONA!!!)
#set +v

##########
# DOCS. #
#########
# Para configurar RELAY DE CORREO
# http://www.cyberciti.biz/tips/linux-use-gmail-as-a-smarthost.html

################
# PARAMETROS #
###############

# Fichero Logs (Verificar que tiene permisos!!)
LOG_FILE=./logs

# Path para guardar imágenes temporalmente (Verificar que tiene permisos!!)
# NO AÑADIR BARRA FINAL!!!
IMAGES_TEMP_FOLDER=./TEMP_PHOTOS

# Filename para las fotos
IMAGE_FILENAME=`date "+%Y%m%d"_"%H%M%S"`_IMAGEN.JPG

# Filename temporal para cuerpo mail
MAIL_TEMP_TEXT=./`date "+%Y%m%d"_"%H%M%S"`_MAIL

# e-mail destino de alertas
DST_MAIL=personajeje@gmail.com


##############
# FUNCIONES #
#############

# Función LOG
# Imprime mensajes en fichero de log
# Sintaxis:	log "Texto que se quiere sacar por fichero logs"

function log() 
{
 echo `date "+%Y%m%d"_"%H%M%S"` - $1 >>  $LOG_FILE
}

# Función COMPROBAR_DEPENDENCIAS
# Comprueba que está instalado un paquete
# Sintaxis:	comprobar_depencia NOMBRE_PAQUETE

function comprobar_depencia ()
{
 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
 log "Comprobando librería: $PKG_OK"
 if [ "" == "$PKG_OK" ]; then
    log "La librería $PKG_OK no está instalada. No se puede continuar."
 fi
}

# Función CREAR_CARPETA
# Comprueba si existe la carpeta y, en caso negativo, la crea.
# Sintaxis:	crear_carpeta FOLDER_PATH
function crear_carpeta()
{
 FOLDER_PATH=$1
 if [[ ! -d $FOLDER_PATH ]]
 then
    mkdir $FOLDER_PATH
    log "Creada carpeta: $FOLDER_PATH"
 fi
}

# Función SEND_MAIL
# Envía mensajes por correo.
# Sintaxis:	send_mail "EMAIL" "SUBJECT" "MESSAGE_TXT_FILE"

function send_mail ()
{
 EMAIL=$1
 SUBJECT=$2
 MESSAGE_TXT_FILE=$3

 mail -s $SUBJECT $EMAIL < $MESSAGE_TXT_FILE
 log "Correo enviado a $EMAIL con asunto $SUBJECT"
}

# Función CAPTURAR_FOTO
# Captura una foto y la almacena en disco

function capturar_foto()
{
 crear_carpeta $IMAGES_TEMP_FOLDER
 cd $IMAGES_TEMP_FOLDER
 echo $IMAGE_FILENAME
 touch $IMAGE_FILENAME
 gphoto2 --capture-image-and-download  # Se dispara la foto. Comentado pq la Ixus no captura!!!
 gphoto2 -p 1 # Se descarga la foto. (Simplemente se descarga la primera y última foto.)
 cd -
 gphoto2 -d 1 # Se borra la foto de la tarjeta. (Simplemente se borra la primera y última foto.)
}


###########
# CUERPO #
##########
touch $MAIL_TEMP_TEXT
comprobar_depencia gphoto2
capturar_foto >> $MAIL_TEMP_TEXT
send_mail  "$DST_MAIL" "`date "+%Y%m%d"_"%H%M%S"`_ASUNTO" $MAIL_TEMP_TEXT
exit 0

#/*comprobar_dependencias
#capturar_foto

#si (subir_foto_ftp) sin error
#	- log "foto tomada"
#	otro caso
#		- log "error al tomar foto"
