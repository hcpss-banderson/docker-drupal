ARG PHPVERSION=8.3
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

RUN wget https://github.com/Metadrop/drupal-fix-permissions-script/archive/refs/tags/v1.0.1.tar.gz \
  && tar -xzf v1.0.1.tar.gz \
  && rm v1.0.1.tar.gz \
  && mv drupal-fix-permissions-script-1.0.1/autofix-drupal-perms.sh /usr/local/bin/autofix-drupal-perms.sh \
  && mv drupal-fix-permissions-script-1.0.1/drupal_fix_permissions.sh /usr/local/bin/drupal_fix_permissions.sh


RUN a2enmod rewrite

COPY config/000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN mkdir -p /var/www/drupal
WORKDIR /var/www/drupal

EXPOSE 80

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]

FROM base AS build
# Depricated

# Create the Drupal structure
ONBUILD COPY drupal/web/modules/custom             /var/www/drupal/web/modules/custom
ONBUILD COPY drupal/web/themes/custom              /var/www/drupal/web/themes/custom
ONBUILD COPY drupal/composer.json                  /var/www/drupal/composer.json
ONBUILD COPY drupal/composer.lock                  /var/www/drupal/composer.lock
ONBUILD COPY drupal/config                         /var/www/drupal/config
ONBUILD COPY drupal/web/sites/default/settings.php /var/www/drupal/web/sites/default/settings.php

ONBUILD ENTRYPOINT ["/entrypoint.sh"]
ONBUILD CMD ["apache2-foreground"]
