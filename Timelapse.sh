#!/bin/bash

# Silencia la salida por pantalla (NO FUNCIONA!!!)
#set +v

##########
# DOCS. #
#########
# Para configurar RELAY DE CORREO
# http://www.cyberciti.biz/tips/linux-use-gmail-as-a-smarthost.html

# Refs.
# - Doc. sobre bash
# http://www.linux-es.org/node/238
# - Bash: Error checking
# http://www.davidpashley.com/articles/writing-robust-shell-scripts.html

################
# PARAMETROS #
###############

# Función LOG
LOG_PATH=/home/pi/TimeLapse/Logs            # (Verificar que tiene permisos!!) .NO AÑADIR BARRA FINAL!!!
LOG_FILE=TimeLapse_`date "+%Y%m%d"`.log     # Fichero Logs (Verificar que tiene permisos!!)

# Función SEND_MAIL
EMAIL=personajeje@gmail.com
MESSAGE_TXT_FILE=`date "+%Y%m%d"_"%H%M%S"`_MAIL

# Función USB_CAMERA_RESET
USB_RESET_COMMAND=/home/pi/TimeLapse/usbreset

# Función CAPTURAR_FOTO
IMAGES_TEMP_FOLDER=./Fotos      # Path para guardar imágenes temporalmente (Verificar que tiene permisos!!) .NO AÑADIR BARRA FINAL!!!
IMAGE_FILENAME=`date "+%Y%m%d"_"%H%M%S"`_IMAGEN.JPG

##############
# FUNCIONES #
#############

# Función CREAR_CARPETA
# Comprueba si existe la carpeta y, en caso negativo, la crea.
# Sintaxis:	crear_carpeta FOLDER_PATH
function crear_carpeta()
{
 FOLDER_PATH=$1
 if [[ ! -d $FOLDER_PATH ]]
 then
    mkdir -p $FOLDER_PATH
 fi
}


# Función LOG
# Imprime mensajes en fichero de log
# Sintaxis:	log "Texto que se quiere sacar por fichero logs"

function log() 
{
 if [[ ! -fw $LOG_FILE ]]
 then
    echo `date "+%Y%m%d"_"%H%M%S"` - $1 >>  $LOG_FILE
 else
    crear_carpeta $LOG_PATH
    touch $LOG_FILE
    echo `date "+%Y%m%d"_"%H%M%S"` - $1 >>  $LOG_FILE
 fi
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

# Función SEND_MAIL
# Envía mensajes por correo.
# Sintaxis:	send_mail "EMAIL" "SUBJECT" "MESSAGE_TXT_FILE" MESSAGE_TXT_FILES_FOLDER

function send_mail ()
{
 EMAIL=$1
 SUBJECT=$2
 MESSAGE_TXT_FILE=$3

 if [[ ! -f $MESSAGE_TXT_FILE ]]
 then
    mail -s $SUBJECT $EMAIL < $MESSAGE_TXT_FILE
    log "Correo enviado a $EMAIL con asunto $SUBJECT"
 else
    log "SEND_MAIL >>> Error al intentar enviar un correo con asunto $SUBJECT"
 fi
}

# Funcion USB_CAMERA_RESET
# Resetea el bus USB de la cámara, averiguando previamente el DEV de la cámara.
# Sintaxis: usb_camera_reset 

function usb_camera_reset()
{
 dev=`gphoto2 --auto-detect | grep usb | cut -b 36-42 | sed 's/,/\//'`
 if [ -z ${dev} ]
 then
    log "USB_CAMERA_RESET >>> Error: Camera not found"
 else
    $USB_RESET_COMMAND /dev/bus/usb/${dev}
    log "USB_CAMERA_RESET >>> Reseteado /dev/bus/usb/${dev}"
 fi
}

# Función CAPTURAR_FOTO
# Captura una foto y la almacena en disco
# Sintaxis: capturar_foto IMAGES_TEMP_FOLDER IMAGE_FILENAME

function capturar_foto()
{
 IMAGES_TEMP_FOLDER=$1
 IMAGE_FILENAME=$2
 IMAGE_FILENAME=$IMAGES_TEMP_FOLDER/$IMAGE_FILENAME

 crear_carpeta $IMAGES_TEMP_FOLDER
 # Se toma la foto
 gphoto2 --capture-image-and-download --filename=$IMAGE_FILENAME
 # Se chequea si el comando ha generado algún error
 if [ "$?"-ne 0];
 then
    # Caso de error, se resetea el USB una vez a ver si se arregla y se reintenta
    # Esto se hace pensando en que la primera vez que se ejecutara el script (previo a cualquier reset), la cámara ya estuviera colgada por algún motivo.
    usb_camera_reset
    gphoto2 --capture-image-and-download --filename=$IMAGE_FILENAME 2>$MESSAGE_TXT_FILE # ESTO ES TEMPORAL. DEBE VOLCAR LA SALIDA A FICHERO DE LOGS
    if [ "$?"-ne 0];
    then
        send_mail "$EMAIL" "Fallo al capturar imagen: $IMAGE_FILENAME" "$MESSAGE_TXT_FILE"
        
 else
    echo "command failed"; exit 1; fi

 log "CAPTURAR_FOTO >>> Foto: $IMAGE_FILENAME"
 # Se resetea el USB para evitar cuelge de la cámara
 usb_camera_reset
}



###########
# CUERPO #
##########

capturar_foto $IMAGES_TEMP_FOLDER $IMAGE_FILENAME
exit 0



#touch $MAIL_TEMP_TEXT
#comprobar_depencia gphoto2
#capturar_foto >> $MAIL_TEMP_TEXT
#send_mail  "$DST_MAIL" "`date "+%Y%m%d"_"%H%M%S"`_ASUNTO" $MAIL_TEMP_TEXT
#exit 0

#/*comprobar_dependencias
#capturar_foto

#si (subir_foto_ftp) sin error
#	- log "foto tomada"
#	otro caso
#		- log "error al tomar foto"


# El programa tiene dos partes
# - Configurar entorno
# - Disparar foto, según configuración







