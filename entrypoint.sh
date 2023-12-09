#!/bin/bash

# terminate on errors
set -e

ENV_EXAMPLE="/var/www/html/.env.example"

# Check if volume is empty
if [ ! -e '/var/www/html/public/index.php' ]; then
    echo 'Setting up lsky-pro volume'
    # Copy lsky-pro from LskyPro src to volume
    cp -a /usr/src/lsky-pro/* /var/www/html/
    cp -a /usr/src/lsky-pro/.env.example /var/www/html
    # Configure authorization parameters, which will be copied and initialized internally to .env
    sed -i 's!APP_URL=.*$!APP_URL='${APP_URL}'!g' ${ENV_EXAMPLE}
    sed -i 's!APP_SERIAL_NO=.*$!APP_SERIAL_NO='${APP_SERIAL_NO}'!g' ${ENV_EXAMPLE}
    sed -i 's!APP_SECRET=.*$!APP_SECRET='${APP_SECRET}'!g' ${ENV_EXAMPLE}
fi

chown -R www-data /var/www/html
chgrp -R www-data /var/www/html
chmod -R 755 /var/www/html/

exec "$@"
