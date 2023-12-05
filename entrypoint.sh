#!/bin/bash
set -eu

WEB_PORT=${WEB_PORT:-80}
ENV_EXAMPLE="/var/www/html/.env.example"

envsubst '${WEB_PORT}' < /etc/apache2/sites-enabled/000-default.conf.template > /etc/apache2/sites-enabled/000-default.conf
envsubst '${WEB_PORT}' < /etc/apache2/ports.conf.template > /etc/apache2/ports.conf

if [ ! -e '/var/www/html/public/index.php' ]; then
    cp -a /var/www/lsky/* /var/www/html/
    cp -a /var/www/lsky/.env.example /var/www/html
    # 配置授权参数，内部会进行拷贝及初始化到.env
    sed -i 's!APP_URL=.*$!APP_URL='${APP_URL}'!g' ${ENV_EXAMPLE}
    sed -i 's!APP_SERIAL_NO=.*$!APP_SERIAL_NO='${APP_SERIAL_NO}'!g' ${ENV_EXAMPLE}
    sed -i 's!APP_SECRET=.*$!APP_SECRET='${APP_SECRET}'!g' ${ENV_EXAMPLE}
fi
    chown -R www-data /var/www/html
    chgrp -R www-data /var/www/html
    chmod -R 755 /var/www/html/

# 后台运行redis
redis-server &
# 后台运行apatch
apachectl -D FOREGROUND
# 配置队列处理进程
nohup php artisan queue:work --queue=emails,images,thumbnails &

exec "$@"
