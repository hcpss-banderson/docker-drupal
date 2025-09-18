ARG PHPVERSION=8.3
FROM dunglas/frankenphp:1-php${PHPVERSION}

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN install-php-extensions \
    apcu \
    gd \
    opcache \
    pdo_mysql \
    zip \
    bcmath \
    intl \
    imap \
    uploadprogress

COPY --from=composer/composer:2-bin /composer /usr/local/bin/

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

WORKDIR /var/www/drupal
COPY Caddyfile /etc/caddy/Caddyfile
ENV PATH=${PATH}:/var/www/drupal/vendor/bin
