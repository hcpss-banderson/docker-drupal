FROM bander2/drupal-php-apache

ENV SCHOOLCODE bses

RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget https://github.com/bander2/twit/releases/download/1.1.0/twit-linux-amd64 -O /usr/local/bin/twit \
    && chmod u+x /usr/local/bin/twit \
    && rm -rf /var/lib/apt/lists/*

COPY templates/* /srv/templates/

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
