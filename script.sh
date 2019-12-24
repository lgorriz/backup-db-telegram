#!/usr/bin/env bash

SERVER="PROD"
HOST="{ip_host}"
PORT="{port_db}"
USER="{user_db}"
PASS="{pass_db}"

# Telegram notifications
AVISO=true
TOKEN="{token_telegram}
CHAT="{chat_id}"
# Configuración general

WORKING_DIR="$(pwd)"
OUTPUT_DIR="/backups"
ARSAT_DIR="/mnt/backup"
nuevoAviso(){
   curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage -d chat_id=$CHAT -d text="$1" >> /dev/null
}

generateBackup(){
   mysqldump -P $2 -h $1 -u$3 -p$4 --all-databases >> "$5/dump.sql"
   if [ $? -ne 0 ];then
        echo "--------------------->ERROR"
        if [ $AVISO ];then
                nuevoAviso "Error al generar el dump del  $SERVER finalizado a las $(date "+%H:%M:%S")"
        fi
        exit 1
   fi;
   echo "--------------------->OK"
}

compress(){
    zip "$1".zip dump.sql
    if [ $? -ne 0 ];then
        echo "--------------------->ERROR"
        if [ $AVISO ];then
                nuevoAviso "Error al comprimir el dump - $SERVER finalizado a las $(date "+%H:%M:%S")"
        fi
        exit 1
    fi;
    echo "--------------------->OK"
}

clean(){
    rm -f "$1/dump.sql"
    if [ $? -ne 0 ];then
        echo "--------------------->ERROR"
        if [ $AVISO ];then
                nuevoAviso "Error al limpiar el directorio - $SERVER finalizado a las $(date "+%H:%M:%S")"
        fi
        exit 1
    fi;
    echo "--------------------->OK"
}

# ------------------------------------ INICIO DEL SCRIPT ---------------------------------------------------
#Verficiaciones Previas

if [ ! -d "$OUTPUT_DIR" ];then
        mkdir $OUTPUT_DIR
fi

# Fin verificaciones previas
echo -e "\n ###################### $(date) ######################### \n"
echo -e "Directorio de trabajo: $WORKING_DIR"
echo "---> Generando backup"
generateBackup $HOST $PORT $USER $PASS $WORKING_DIR
echo "---> Comprimiendo"
compress "$OUTPUT_DIR/$(date +"%m_%d_%Y")_$SERVER"
echo "---> Comprimiendo"
compress "$ARSAT_DIR/$(date +"%m_%d_%Y")_$SERVER"
echo "---> Clean"
clean $WORKING_DIR
if [ $AVISO ];then
        nuevoAviso "Backup exitoso para el servidor $SERVER finalizado a las $(date "+%H:%M:%S")"
fi