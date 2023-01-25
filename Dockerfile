FROM php:8.0-apache-buster

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
    bcmath \
    gd \
    pdo_mysql \
    intl \
    apcu \
    zip \
    opcache \
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

# Global Drush
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar \
  && chmod +x drush.phar \
  && mv drush.phar /usr/local/bin/drush

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

ONBUILD RUN composer install -d /var/www/drupal

COPY entrypoint.sh /entrypoint.sh
ONBUILD ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
ONBUILD CMD ["apache2-foreground"]
