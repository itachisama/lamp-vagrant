#!/usr/bin/env bash

# Capturo o primeiro parâmetro e configuro o nome padrão da box em $DEV_ENV
[ "$1" ] && DEV_ENV=$1 || DEV_ENV="epic.local.dev"

# Arquivo destino de configuração virtualhost
FILE_VHOST="/etc/httpd/vhosts/${DEV_ENV}.conf"

# Arquivo de hosts da máquina virtual
FILE_HOSTS="/etc/hosts"

# Monto o arquivo de configuração do virtualhost do apache
VHOST=$(cat <<EOF
<VirtualHost *:8000>
    ServerAdmin webmaster@${DEV_ENV}
    ServerName ${DEV_ENV}
    ServerAlias ${DEV_ENV}.*.xip.io

    DocumentRoot "/var/www/html/dev/public"
    <Directory "/var/www/html/dev/public">
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
    ErrorLog "logs/${DEV_ENV}-error.log"
    CustomLog "logs/${DEV_ENV}-access.log" common
</VirtualHost>
EOF
)

HOST=$(cat <<EOF
127.0.0.1	${DEV_ENV}
EOF
)

# Escrevo o arquivo recém configurado na pasta do apache destinada ao virtualhost
echo "${VHOST}" > $FILE_VHOST

# Escrevo o arquivo no arquivo de hosts da máquina virtual
echo "${HOST}" >> $FILE_HOSTS

# Instalo o composer na máquina virtual
/usr/bin/curl -s https://getcomposer.org/installer | /usr/bin/php

# Disponibilizo o composer de forma global
mv composer.phar /usr/local/bin/composer

# Reinicio o apache

/sbin/service httpd restart
