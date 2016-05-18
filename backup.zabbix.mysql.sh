#!/bin/bash
# Script: backup.zabbix.mysql
# Versão: 2.0
# Autor: Diego Cavalcante
# Data: Dom Mai 01 17:30:32 BRT 2016
# Revisão: Wed Mai 18 16:29:00 BRT 2016
# Site: www.suportecavalcante.com.br
# Email: <diego@suportecavalcante.com.br>
# Descrição: Backup do banco de dados mysql zabbix

BACKUPDIR="/var/backup/zabbix/mysql"
DATE=`date +%d%m%Y`
DATELOG=`date +%d-%m-%y_%H:%M:%S`
LOG="/var/log/backup.zabbix.mysql.log"
USER="mysqlusuario"
PASSWORD="mysqlsenha"
DATABASE="nomedobanco"
# IP="IP DO ZABBIX SERVER OU PROXY"
# HOSTNAME="NOMEDOHOST"
# ITEMKEY="backup.zabbix.mysql.status"
# VALOR="OK"

# Inicio de Backup - Log
echo "Iniciando Backup: $DATELOG" >> $LOG

# Backup
echo "Backup Database Zabbix: $DATELOG" >> $LOG
mysqldump -u"$USER" --password="$PASSWORD" -x -e -B $DATABASE > $BACKUPDIR/$DATABASE.$DATE.sql

# Compactando Backup - Log
echo "Compactando Backup: $DATELOG" >> $LOG
bzip2 $BACKUPDIR/$DATABASE.$DATE.sql

# Remove Backups mais antigos 7 dias
echo "Removendo Backups Antigos: $DATELOG" >> $LOG
ls -td1 $BACKUPDIR/* | sed -e '1,7d' | xargs -d '\n' rm -rif

# Zabbix Sender - Apenas se o backup for realizado com sucesso, descomente caso deseje usar
# zabbix_sender -z $IP -s "$HOSTNAME" -k $ITEMKEY -o $VALOR
echo "Backup Finalizado com Sucesso: $DATELOG" >> $LOG
