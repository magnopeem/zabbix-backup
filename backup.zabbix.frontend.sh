#!/bin/bash
# Script: backup.zabbix.frontend
# Versão: 3.0
# Autor: Diego Cavalcante
# Data: Dom Mai 01 17:30:32 BRT 2016
# Revisão: Wed Mai 18 16:29:00 BRT 2016
# Site: www.suportecavalcante.com.br
# Email: <diego@suportecavalcante.com.br>
# Descrição: Backup de arquivos importantes do zabbix e sistema

BACKUPDIR="/var/backup/zabbix/frontend"
DATE=`date +%d%m%Y`
DATELOG=`date +%d-%m-%y_%H:%M:%S`
TEMP="Files"
NOME="frontend"
LOG="/var/log/backup.zabbix.frontend.log"
# IP="IP DO ZABBIX SERVER OU PROXY"
# HOSTNAME="NOMEDOHOST"
# ITEMKEY="backup.zabbix.frontend.status"
# VALOR="OK"

# Inicio de Backup - Log
echo "Iniciando Backup: $DATELOG" >> $LOG

# Cria diretório temporário Files
echo "Criando Diretório: $DATELOG" >> $LOG
mkdir $BACKUPDIR/$TEMP
mkdir $BACKUPDIR/$TEMP/zabbix
mkdir $BACKUPDIR/$TEMP/mysql
mkdir $BACKUPDIR/$TEMP/cron
mkdir $BACKUPDIR/$TEMP/apache2
mkdir $BACKUPDIR/$TEMP/frontend
mkdir $BACKUPDIR/$TEMP/php5
mkdir $BACKUPDIR/$TEMP/phpmyadmin
mkdir $BACKUPDIR/$TEMP/odbc

# Copia arquivos do frontend e arquivos importantes de configuração
echo "Copiando Arquivos: $DATELOG" >> $LOG
cp -R /etc/zabbix/* $BACKUPDIR/$TEMP/zabbix
cp /etc/mysql/my.cnf $BACKUPDIR/$TEMP/mysql
cp /etc/zabbix/.my.cnf $BACKUPDIR/$TEMP/mysql/my.old.cnf
cp /etc/crontab $BACKUPDIR/$TEMP/cron
cp -R /etc/apache2/* $BACKUPDIR/$TEMP/apache2
cp -R /usr/share/monitoramento/* $BACKUPDIR/$TEMP/frontend
cp /etc/php5/apache2/php.ini $BACKUPDIR/$TEMP/php5
cp /etc/phpmyadmin/apache.conf $BACKUPDIR/$TEMP/phpmyadmin
cp /etc/phpmyadmin/config-db.php $BACKUPDIR/$TEMP/phpmyadmin
cp /etc/odbc.ini $BACKUPDIR/$TEMP/odbc
cp /etc/odbcinst.ini $BACKUPDIR/$TEMP/odbc

# Compactando o Backup, copiando e removendo diretório temporário
echo "Compactando Backup: $DATELOG" >> $LOG
cd $BACKUPDIR/$TEMP
tar czf $NOME.$DATE.tar.gz *
cp $NOME.$DATE.tar.gz /$BACKUPDIR
cd $BACKUPDIR
rm -r $BACKUPDIR/$TEMP

# Remove Backups mais antigos 7 dias
echo "Removendo Backups Antigos: $DATELOG" >> $LOG
ls -td1 $BACKUPDIR/* | sed -e '1,7d' | xargs -d '\n' rm -rif

# Zabbix Sender - Apenas se o backup for realizado com sucesso, descomente caso deseje usar
# zabbix_sender -z $IP -s "$HOSTNAME" -k $ITEMKEY -o $VALOR
echo "Backup Finalizado com Sucesso: $DATELOG" >> $LOG
