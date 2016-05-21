#!/bin/bash
# Script: backup.zabbix.frontend
# Versão: 3.0
# Autor: Diego Cavalcante
# Data: Dom Mai 01 17:30:32 BRT 2016
# Revisão: Sat Mai 21 13:25:00 BRT 2016
# Site: www.suportecavalcante.com.br
# Email: <diego@suportecavalcante.com.br>
# Descrição: Backup de arquivos importantes do zabbix e sistema

# Variáveis
BACKUPDIR="/var/backup/zabbix/frontend"
DATA=`date +%d%m%Y`
DATALOG=`date +%d%m%Y_%H:%M:%S`
TEMP="Files"
NOME="frontend"
LOG="/var/log/backup.zabbix.frontend.log"
IP="127.0.0.1"
HOSTNAME="HOSTNAME DO ZABBIX SERVER"
ITEMKEY="backup.zabbix.frontend.status"
ITEMKEYERRO="backup.zabbix.frontend.status.erro"
SUCESSO="OK"
ERROPASSO1="erro.criacao.subdiretorios"
ERROPASSO2="erro.indefinido"
ERROPASSO3="erro.compactacao"
ERROPASSO4="erro.rotacao"

# Verificando existência do diretório principal
if [ -e $BACKUPDIR ]
   then
   echo "Diretorio principal ja existe"
else
   mkdir $BACKUPDIR
   echo "Diretorio principal criado com sucesso"
   echo "Diretorio principal criado com sucesso: $DATALOG" >> $LOG
   continue
fi
 
# PASSO 01 - Cria sub-diretório no diretório principal
echo "Criando sub-diretorios: $DATALOG" >> $LOG
mkdir -p $BACKUPDIR/$TEMP
mkdir -p $BACKUPDIR/$TEMP/zabbix
mkdir -p $BACKUPDIR/$TEMP/mysql
mkdir -p $BACKUPDIR/$TEMP/cron
mkdir -p $BACKUPDIR/$TEMP/apache2
mkdir -p $BACKUPDIR/$TEMP/frontend
mkdir -p $BACKUPDIR/$TEMP/php5
mkdir -p $BACKUPDIR/$TEMP/phpmyadmin
mkdir -p $BACKUPDIR/$TEMP/odbc
numero=`ls $BACKUPDIR/$TEMP | wc -w`
if [ $numero -eq 8 ]; then
    echo "Sub-diretorios criados com sucesso, Total 08"
    echo "Sub-diretorios criados com sucesso, Total 08: $DATALOG" >> $LOG
else
    zabbix_sender -z $IP -s "$HOSTNAME" -k $ITEMKEYERRO -o $ERROPASSO1
    echo "Erro na criacao dos sub-diretorios PASSO 01"
    echo "Erro na criacao dos sub-diretorios PASSO 01: $DATALOG" >> $LOG
    exit 0
fi
 
# PASSO 02 - Copia arquivos do frontend e arquivos importantes de configuração
echo "Copiando Arquivos: $DATALOG" >> $LOG
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

# PASSO 03 - Compactando o Backup, copiando e removendo diretório temporário
echo "Compactando Backup: $DATALOG" >> $LOG
cd $BACKUPDIR/$TEMP
tar czf $NOME.$DATA.tar.gz *
if [ -e $BACKUPDIR/$TEMP/$NOME.$DATA.tar.gz ]; then
   echo "Backup compactado com sucesso"
   echo "Backup compactado com sucesso: $DATALOG" >> $LOG
else
   zabbix_sender -z $IP -s "$HOSTNAME" -k $ITEMKEYERRO -o $ERROPASSO3
   echo "Erro na compactacao do backup PASSO 03"
   echo "Erro na compactacao do backup PASSO 03: $DATALOG" >> $LOG
   exit 0
fi
cp $NOME.$DATA.tar.gz /$BACKUPDIR
cd $BACKUPDIR
rm -r $BACKUPDIR/$TEMP

# PASSO 04 - Remove Backups mais antigos 7 dias
echo "Removendo Backups Antigos: $DATA" >> $LOG
ls -td1 $BACKUPDIR/* | sed -e '1,7d' | xargs -d '\n' rm -rif
numero=`ls $BACKUPDIR | wc -w`
if [ $numero -eq 7 ]; then
    echo "Backup Local rotacionado com sucesso, Total 07"
    echo "Backup Local rotacionado com sucesso, Total 07: $DATA" >> $LOG
else
    zabbix_sender -z $IP -s "$HOSTNAME" -k $ITEMKEYERRO -o $ERROPASSO4
    echo "Erro na rotacao do backup PASSO 04"
    echo "Erro na rotacao do backup PASSO 04: $DATA" >> $LOG
    exit 0
fi

# PASSO 05 - Zabbix Sender Final - Apenas se o backup for realizado com sucesso
zabbix_sender -z $IP -s "$HOSTNAME" -k $ITEMKEY -o $SUCESSO
echo "Backup finalizado com sucesso:"
echo "Backup finalizado com sucesso: $DATALOG" >> $LOG
