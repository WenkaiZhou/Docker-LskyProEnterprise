#!/bin/bash

# terminate on errors
set -e

ENV_FILE="/var/www/html/.env.example"

# Check if volume is empty
if [ ! -e '/var/www/html/public/index.php' ]; then
    echo 'Setting up lsky-pro volume'
    # Copy lsky-pro from LskyPro src to volume
    cp -a /usr/src/lsky-pro/* /var/www/html/
    cp -a /usr/src/lsky-pro/.env.example ${ENV_FILE}
    # Configure authorization parameters
    echo 'Configure authorization parameters'
    sed -i 's!APP_URL=.*$!APP_URL='${APP_URL}'!g' ${ENV_FILE}
    sed -i 's!APP_SERIAL_NO=.*$!APP_SERIAL_NO='${APP_SERIAL_NO}'!g' ${ENV_FILE}
    sed -i 's!APP_SECRET=.*$!APP_SECRET='${APP_SECRET}'!g' ${ENV_FILE}
    chmod www-data:www-data ${ENV_FILE}
fi

# Make sure that the html file is readable by www-data user
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

exec "$@"
