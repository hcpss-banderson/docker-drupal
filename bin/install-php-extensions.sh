#!/usr/bin/env bash

apt-get update && apt-get install -y \
        libfreetype-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libicu-dev \
        libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        bcmath \
        pdo_mysql \
        intl \
        zip \
        opcache \
    && pecl install apcu uploadprogress \
    && docker-php-ext-enable apcu uploadprogress \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
