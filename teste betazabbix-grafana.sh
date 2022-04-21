#!/usr/bin/env bash

clear

echo "instalação dos repositorios zabbix 6.0 para o Debian"
echo "----------------------------------------------------"
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian11_all.deb

echo "Aguarde um pouco"
dpkg -i zabbix-release_6.0-1+debian11_all.deb

echo "Estamos atualizando seus repositorios"
apt update

echo "Instalação do servidor, frontend e o agente Zabbix"
echo "**************************************************"
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent apache2

echo "Vamos instalar o MARIADB!"
apt update
apt upgrade
echo "Aguarde que estamos instalando o MariaDB, isso pode demorar um pouquinho"
apt install mariadb-server mariadb-client-10.5 mariadb-client-core-10.5 mariadb-common mariadb-server-10.5 mariadb-server-core-10.5

echo "reiciando serviço do mariadb"
systemctl restart mariadb-server

echo "acredito que tenha ocorrido todo ok com sua instalação de DB"
echo "____________________________________________________________"

echo "hora de vc colocar a senha do seu banco de dados"
echo "Por favor atenção não esqueça sua senha"
echo "¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨"

echo -n "DIGITE SUA SENHA: "
mysql -uroot -p
echo "ESCREVA ESSA INSTRUÇÕES NO BANCO DE DADOS"

echo "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
echo "create user zabbix@localhost identified by 'suasenha';"
echo "grant all privileges on zabbix.* to zabbix@localhost;"
echo "quit;"

mysql -e "create database zabbix character set utf8 collate utf8_bin"
mysql -e "create user 'zabbix'@'localhost' identified by 'zabbix'"
mysql -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' with grant option";

echo "aguarde um momento"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------"
zcat /usr/share/doc/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p zabbix
echo "##############################################################################################################################################################"

echo "precisaremos do nano"
apt install nano
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "**************************************************************************************************************************************************************"
echo "Editar arquivo /etc/zabbix/zabbix_server.conf"
echo "Edite essa linha e coloque sua senha - DBPassword=password"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

nano /etc/zabbix/zabbix_server.conf

echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "ajustar timezone para America/Santarem"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

nano /etc/zabbix/apache.conf

echo "reiciando e fixado os serviços zabbix-server zabbix-agent apache2"
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

clear

echo "Download&INSTALÇÃO Grafana"
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_8.4.7_amd64.deb
sudo dpkg -i grafana-enterprise_8.4.7_amd64.deb

echo "Plugin de integração"

grafana-cli plugins install alexanderzobnin-zabbix-app
service grafana-server restart
