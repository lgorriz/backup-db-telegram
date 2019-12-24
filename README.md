# Realizar un backup de BD Mysql en Centos y enviar notificación a Telegram

Se deben setear las configuraciones de la BD y del ID de telegram

Desde el crontab de linux se puede programar para llamarlo de esta manera
#####Ej:
30 20   * * * /root/backup.sh >/dev/null 2>&1