ARG PHPVERSION=8.3
FROM php:$PHPVERSION-apache

ENV PATH="${PATH}:/var/www/drupal/vendor/bin"
ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=composer/composer:2-bin /composer /usr/local/bin/
COPY bin /docker-bin

RUN /docker-bin/install-composer-dependencies.sh
RUN /docker-bin/install-php-extensions.sh
RUN /docker-bin/install-common.sh
RUN /docker-bin/install-fix-permissions.sh

RUN a2enmod rewrite

COPY mod_php/000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN mkdir -p /var/www/drupal
WORKDIR /var/www/drupal

EXPOSE 80

ENTRYPOINT ["/docker-bin/entrypoint.sh"]
CMD ["apache2-foreground"]
