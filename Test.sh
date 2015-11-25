#!/bin/bash

if ! ping -c 3 80.59.91.157
 then
    echo NOK
    #log "CAPTURAR_FOTO >>> Fallo al capturar imagen: $IMAGE_FILENAME"
    #send_mail "$EMAIL" "Fallo al capturar imagen: $IMAGE_FILENAME" "$MESSAGE_TXT_FILE"
    exit 1
 else
    echo ok
    #log "CAPTURAR_FOTO >>> Foto: $IMAGE_FILENAME"

 fi


exit 0
