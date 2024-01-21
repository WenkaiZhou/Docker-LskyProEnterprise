ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="WenkaiZhou <zwenkai@foxmail.com>"
LABEL Description="Lightweight LskyPro container with Nginx 1.24 & PHP-FPM 8.2 based on Alpine Linux."

# Ensure www-data user exists
RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

# Install packages and remove default server definition
RUN apk add --no-cache \
  bash \
  curl \
  nginx \
  redis \
  php82 \
  php82-ctype \
  php82-curl \
  php82-dom \
  php82-fileinfo \
  php82-fpm \
  php82-gd \
  php82-intl \
  php82-mbstring \
  php82-mysqli \
  php82-pdo \
  php82-pdo_mysql \
  php82-opcache \
  php82-openssl \
  php82-phar \
  php82-session \
  php82-tokenizer \
  php82-xml \
  php82-xmlreader \
  php82-xmlwriter \
  php82-bcmath \
  php82-pecl-redis \
  php82-pecl-imagick \
  php82-zip \
  supervisor

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
ENV PHP_INI_DIR /etc/php82
COPY config/fpm-pool.conf ${PHP_INI_DIR}/php-fpm.d/www.conf
COPY config/php.ini ${PHP_INI_DIR}/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create symlink for php
RUN ln -s /usr/bin/php82 /usr/bin/php

# LskyPro volume
VOLUME /var/www/html
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www

# LskyPro
RUN mkdir -p /usr/src

COPY lsky-pro.zip .
RUN unzip lsky-pro.zip -d /usr/src/lsky-pro \
    && rm -rf lsky-pro.zip \
    && chown -R www-data:www-data /usr/src/lsky-pro

# Entrypoint to copy lsky-pro
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Make sure files/folders needed by the processes are accessable when they run under the www-data user
RUN chown -R www-data:www-data /var/www/html /run /var/lib/nginx /var/log/nginx

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf", "-u", "www-data"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=30s CMD curl --silent --fail http://127.0.0.1/index.php