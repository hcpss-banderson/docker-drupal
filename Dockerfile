FROM php:8.0-fpm

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
    gd \
    pdo_mysql \
    intl \
    apcu \
    zip \
    opcache \
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

# Global Drush
RUN composer global require drush/drush
ENV PATH="/root/.composer/vendor/bin:$PATH"

# Drupal Console
RUN curl https://drupalconsole.com/installer -L -o drupal.phar \
  && mv drupal.phar /usr/local/bin/drupal \
  && chmod +x /usr/local/bin/drupal

RUN mkdir -p /var/www/drupal
WORKDIR /var/www/drupal
