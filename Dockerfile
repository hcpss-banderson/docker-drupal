FROM php:7.4.14-apache-buster

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
    gd \
    xdebug \
    pdo_mysql \
    intl \
    apcu \
    zip \
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
RUN composer global require consolidation/cgr
ENV PATH="/root/.composer/vendor/bin:$PATH"
RUN cgr drush/drush

# Drupal Console
RUN curl https://drupalconsole.com/installer -L -o drupal.phar \
  && mv drupal.phar /usr/local/bin/drupal \
  && chmod +x /usr/local/bin/drupal

COPY config/000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN mkdir -p /var/www/drupal
WORKDIR /var/www/drupal

EXPOSE 80
