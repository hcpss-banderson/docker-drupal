ARG PHPVERSION=8.2
FROM php:$PHPVERSION-apache-bookworm AS base

ENV PATH="${PATH}:/var/www/drupal/vendor/bin"
ENV COMPOSER_ALLOW_SUPERUSER=1

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
    bcmath \
    gd \
    pdo_mysql \
    intl \
    apcu \
    zip \
    opcache \
    imap \
    uploadprogress \
    @composer \
  && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update && apt-get install -y --no-install-recommends \
    git \
    zip \
    unzip \
    xz-utils \
    curl \
    wget \
    default-mysql-client \
    openssl \
    ca-certificates \
    patch \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

COPY config/000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN mkdir -p /var/www/drupal
WORKDIR /var/www/drupal

EXPOSE 80

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]

FROM base AS build

# Create the Drupal structure
ONBUILD COPY --chown=root:www-data --chmod=640 drupal/web/modules/custom             /var/www/drupal/web/modules/custom
ONBUILD COPY --chown=root:www-data --chmod=640 drupal/web/themes/custom              /var/www/drupal/web/themes/custom
ONBUILD COPY --chown=root:www-data --chmod=640 drupal/composer.json                  /var/www/drupal/composer.json
ONBUILD COPY --chown=root:www-data --chmod=640 drupal/composer.lock                  /var/www/drupal/composer.lock
ONBUILD COPY --chown=root:www-data --chmod=640 drupal/config                         /var/www/drupal/config
ONBUILD COPY --chown=root:www-data --chmod=640 drupal/web/sites/default/settings.php /var/www/drupal/web/sites/default/settings.php

ONBUILD ENTRYPOINT ["/entrypoint.sh"]
ONBUILD CMD ["apache2-foreground"]
