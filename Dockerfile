FROM php:7.2-fpm-alpine

LABEL maintainer="Brendan Anderson <brendan_anderson@hcpss.org>"

# Configure PHP for running Drupal.
RUN apk add --no-cache --virtual .php-run-deps \
        libpng \
        libjpeg-turbo \
        freetype \
        icu-dev \
        zlib-dev \
        libzip-dev \
    && apk add --no-cache --virtual .php-build-deps \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure zip --with-libzip \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-install -j${NPROC} gd mysqli pdo pdo_mysql intl opcache zip \
    && apk del .php-build-deps

# Configure the system for Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN apk --no-cache add --virtual .composer-rundeps \
    git \
    subversion \
    openssh \
    mercurial \
    tini \
    bash \
    patch \
    make \
    zip \
    unzip

# Configure PHP for Composer
RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" \
    && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "$PHP_INI_DIR/conf.d/date_timezone.ini" \
    && apk add --no-cache --virtual .composer-build-deps zlib-dev libzip-dev \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) zip \
    && apk del .composer-build-deps

# Install Composer
RUN EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)" \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; \
    then \
        >&2 echo 'ERROR: Invalid installer signature'; \
        rm composer-setup.php; \
        exit 1; \
    fi \
    && php composer-setup.php --quiet \
    && rm composer-setup.php \
    && mv composer.phar /usr/local/bin/composer

# Drush Launcher
RUN wget --no-check-certificate -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
	&& chmod +x drush.phar \
    && mv drush.phar /usr/local/bin/drush

RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

RUN mkdir -p /var/www/drupal

VOLUME ["/var/www/drupal"]

WORKDIR /var/www/drupal

ONBUILD COPY drupal/web/autoload.php               /var/www/drupal/web/autoload.php
ONBUILD COPY drupal/web/modules/custom             /var/www/drupal/web/modules/custom
ONBUILD COPY drupal/web/themes/custom              /var/www/drupal/web/themes/custom
ONBUILD COPY drupal/scripts                        /var/www/drupal/scripts
ONBUILD COPY drupal/drush                          /var/www/drupal/drush
ONBUILD COPY drupal/composer.json                  /var/www/drupal/composer.json
ONBUILD COPY drupal/composer.lock                  /var/www/drupal/composer.lock
ONBUILD COPY drupal/config                         /var/www/drupal/config
ONBUILD COPY drupal/web/sites/default/settings.php /var/www/drupal/web/sites/default/settings.php

ONBUILD RUN composer install

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
