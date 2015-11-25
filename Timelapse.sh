#!/bin/bash

# Silencia la salida por pantalla (NO FUNCIONA!!!)
set +v

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
LOG_PATH=/media/tera/Logs            # (Verificar que tiene permisos!!) .NO AÑADIR BARRA FINAL!!!
LOG_FILE=TimeLapse_`date "+%Y%m%d"`.log     # Fichero Logs (Verificar que tiene permisos!!)
LOG_FILE=$LOG_PATH/$LOG_FILE

# Función SEND_MAIL
EMAIL=personajeje@gmail.com
MESSAGE_TXT_FILE=`date "+%Y%m%d"_"%H%M%S"`_MAIL

# Función USB_CAMERA_RESET
USB_RESET_COMMAND=/home/pi/TimeLapse/usbreset

# Función CAPTURAR_FOTO
IMAGES_FOLDER=/media/tera/Fotos      # Path para guardar imágenes (Verificar que tiene permisos!!).NO AÑADIR BARRA FINAL!!!
IMAGE_FILENAME=`date "+%Y%m%d"_"%H%M%S"`

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
 if [[ ! -f $LOG_FILE ]]
 then
    crear_carpeta $LOG_PATH
    touch $LOG_FILE
    echo `date "+%Y%m%d"_"%H%M%S"` - $1 >>  $LOG_FILE
 else
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
 LOG_FILE=$3

 if [[ ! -f "$LOG_FILE" ]]
 then
    mail -s $SUBJECT $EMAIL < "$LOG_FILE"
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
 dev=`/usr/local/bin/gphoto2 --auto-detect | grep usb | cut -b 36-42 | sed 's/,/\//'`
 if [ -z ${dev} ]
 then
    log "USB_CAMERA_RESET >>> Error: Camera not found"
    send_mail "$EMAIL" "Fallo al resetear la camara: $IMAGE_FILENAME" "$LOG_FILE" #"$MESSAGE_TXT_FILE"
    exit 1
 else
    $USB_RESET_COMMAND /dev/bus/usb/${dev}
    log "USB_CAMERA_RESET >>> Reseteado /dev/bus/usb/${dev}"
 fi
}

# Función CAPTURAR_FOTO
# Captura una foto y la almacena en disco
# Sintaxis: capturar_foto IMAGES_FOLDER IMAGE_FILENAME

function capturar_foto()
{
 IMAGES_FOLDER=$1
 IMAGE_FILENAME=$2

 crear_carpeta "$IMAGES_FOLDER"_JPG
 crear_carpeta "$IMAGES_FOLDER"_RAW
 # Primero se resetea el USB para evitar problemas con la cámara
 
 if ! usb_camera_reset; then log "CAPTURAR_FOTO >>> Fallo al resetear el USB"; exit 1; fi

 # Se toma la foto y se chequea si correcto
 #La foto se toma con nombre "capt0000..." en el directorio temporal (por la negativa del gphoto a grabarla sobre el disco directamente). Y el problema de definier el nombre cuando RAW+JPG
 cd /tmp
 # Antes de tomar la foto, se chequea si los fichero ya existieran, para evitar que de error la captura. Si ya existen, se borran.
 if [ -e capt0000.jpg -o -e capt0000.cr2 ]; then
    rm -f capt000*
 fi

# Se toma la foto y se chequea si correcto
 if ! /usr/local/bin/gphoto2 --capture-image-and-download
 then
    log "CAPTURAR_FOTO >>> Fallo al capturar imagen: $IMAGE_FILENAME"
    send_mail "$EMAIL" "Fallo al capturar imagen: $IMAGE_FILENAME" "$MESSAGE_TXT_FILE"
    exit 1
 else
    IMAGE_FILENAME_JPG="$IMAGES_FOLDER"_JPG/$IMAGE_FILENAME
    mv capt0000.jpg $IMAGE_FILENAME_JPG.jpg
    log "CAPTURAR_FOTO >>> Foto: $IMAGE_FILENAME_JPG"
    IMAGE_FILENAME_RAW="$IMAGES_FOLDER"_RAW/$IMAGE_FILENAME   
    mv capt0000.cr2 $IMAGE_FILENAME_RAW.cr2
    log "CAPTURAR_FOTO >>> Foto: $IMAGE_FILENAME_RAW"
 fi
}



###########
# CUERPO #
##########

capturar_foto $IMAGES_FOLDER $IMAGE_FILENAME
exit 0

# El programa tiene dos partes
# - Configurar entorno
# - Disparar foto, según configuracion








