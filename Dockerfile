FROM php:7-fpm-alpine

# env
RUN pecl channel-update pecl.php.net \
  && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS linux-headers zlib-dev

# swoole
# RUN pecl install swoole \
#   && docker-php-ext-enable swoole

# postgres
RUN apk add --no-cache postgresql-dev \
  && docker-php-ext-install pdo pdo_pgsql pgsql

# install composer
RUN apk --no-cache add curl git subversion openssh openssl mercurial tini bash

RUN docker-php-ext-install zip

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.6.5

RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/b107d959a5924af895807021fcef4ffec5a76aa9/web/installer \
 && php -r " \
    \$signature = '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
        unlink('/tmp/installer.php'); \
        echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
        exit(1); \
    }" \
 && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && composer --ansi --version --no-interaction \
 && rm -rf /tmp/* /tmp/.htaccess
# install composer end

RUN pecl install inotify
RUN docker-php-ext-enable inotify

RUN apk del .phpize-deps

WORKDIR /app
