ARG PHPVERSION=8.3
FROM php:$PHPVERSION-fpm

ENV PATH="${PATH}:/var/www/drupal/vendor/bin"
ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=composer/composer:2-bin /composer /usr/local/bin/
COPY bin /docker-bin

RUN /docker-bin/install-composer-dependencies.sh
RUN /docker-bin/install-php-extensions.sh
RUN /docker-bin/install-common.sh
RUN /docker-bin/install-fix-permissions.sh

RUN mkdir -p /var/www/drupal
WORKDIR /var/www/drupal

ENTRYPOINT ["/docker-bin/entrypoint.sh"]
CMD ["apache2-foreground"]
