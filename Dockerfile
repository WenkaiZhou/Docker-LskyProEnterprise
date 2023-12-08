FROM php:8.1-apache
WORKDIR /build

ENV TZ=Asia/Shanghai
ENV APP_SERIAL_NO=""
ENV APP_SECRET=""
ENV APP_URL=""

# 安装依赖和相关拓展
RUN apt-get update \
    && apt-get install -y \
        gettext \
        unzip \
        supervisor \
    # 安装并启用redis扩展
    && apt-get install -y redis-server \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis \
    # 安装并启用imagick扩展
    && apt-get install -y imagemagick libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    # 安装并启用bcmath扩展
    && docker-php-ext-install bcmath \
    && docker-php-ext-enable bcmath \
    # 安装并启用pdo_mysql
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable pdo_mysql \
    # 删除临时文件
    && rm -rf /tmp/pear \
    # 启用Apache的mod_rewrite模块
    && a2enmod rewrite

RUN { \
    echo 'post_max_size = 100M;';\
    echo 'upload_max_filesize = 100M;';\
    echo 'max_execution_time = 600S;';\
    } > /usr/local/etc/php/conf.d/docker-php-upload.ini;

RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.revalidate_freq=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini;

COPY lsky-pro.zip .
RUN unzip lsky-pro.zip \
    && rm -rf lsky-pro.zip \
    && mkdir /var/www/data \
    && chown -R www-data:root /var/www \
    && chmod -R g=u /var/www \
    && mv /build /var/www/lsky/

COPY ./000-default.conf.template /etc/apache2/sites-enabled/
COPY ./ports.conf.template /etc/apache2/
COPY ./lsky-pro-worker.conf /etc/supervisor/conf.d/
COPY entrypoint.sh /
WORKDIR /var/www/html/
VOLUME /var/www/html
ENV WEB_PORT 80
EXPOSE ${WEB_PORT}
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]