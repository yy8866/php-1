# Use Alpine Linux
FROM php:7.1.3-fpm-alpine

# Maintainer
MAINTAINER Connor <connor.niu@gmail.com>

# Set Timezone Environments
ENV TIMEZONE            Asia/Shanghai
RUN \
	apk add --update tzdata && \
	cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
	echo "${TIMEZONE}" > /etc/timezone && \
	apk del tzdata

# Install Software
RUN apk add --no-cache --virtual .ext-deps \
        bash \
        curl \
        git \
        nodejs \
        libjpeg-turbo-dev \
        libwebp-dev \
        libpng-dev \
        libxml2-dev \
        freetype-dev \
        libmcrypt \
        autoconf
RUN \
    docker-php-ext-configure pdo && \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure pdo_dblib && \
    docker-php-ext-configure opcache && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure sockets && \
    docker-php-ext-configure gd && \
    docker-php-ext-configure soap && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-configure pcntl && \
    docker-php-ext-configure sysvsem && \
    docker-php-ext-configure tokenizer && \
    docker-php-ext-configure zlib && \
    docker-php-ext-configure shmop && \
    docker-php-ext-configure xmlrpc && \
    docker-php-ext-configure gettext && \
    docker-php-ext-configure mcrypt && \
    docker-php-ext-configure mysqli && \
    --with-jpeg-dir=/usr/include --with-png-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include

# Install and Enable Redis Xdebug Mongodb
RUN \
    apk add --no-cache --virtual .mongodb-ext-build-deps openssl-dev && \
    pecl install redis && \
    pecl install xdebug && \
    pecl install mongodb && \
    pecl clear-cache && \
    apk del .mongodb-ext-build-deps && \
	docker-php-ext-enable redis.so && \
	docker-php-ext-enable xdebug.so && \
	docker-php-ext-enable mongodb.so

# Install PHP extention
RUN \
    docker-php-ext-install pdo pdo_mysql pdo_dblib opcache exif sockets gd soap bcmath pcntl sysvsem tokenizer zlib shmop xmlrpc gettext mcrypt mysqli && \
    docker-php-source delete

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install APIDoc
RUN npm install apidoc -g

# Install APIDoc for Grunt
RUN npm install grunt-apidoc --save-dev

# Copy php.ini
COPY php.ini /usr/local/etc/php

# Work Directory
WORKDIR /var/www/html

# Expose ports
EXPOSE 9000

# Entry point
CMD ["php-fpm"]
