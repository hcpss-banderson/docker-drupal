FROM php:8.1-apache-buster

ENV PATH="${PATH}:/var/www/drupal/vendor/bin"
ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

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

# Create the Drupal structure
ONBUILD COPY drupal/web/modules/custom             /var/www/drupal/web/modules/custom
ONBUILD COPY drupal/web/themes/custom              /var/www/drupal/web/themes/custom
ONBUILD COPY drupal/composer.json                  /var/www/drupal/composer.json
ONBUILD COPY drupal/composer.lock                  /var/www/drupal/composer.lock
ONBUILD COPY drupal/config                         /var/www/drupal/config
ONBUILD COPY drupal/web/sites/default/settings.php /var/www/drupal/web/sites/default/settings.php

COPY entrypoint.sh /entrypoint.sh
ONBUILD ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
ONBUILD CMD ["apache2-foreground"]
