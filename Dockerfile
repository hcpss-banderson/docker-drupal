FROM ubuntu:xenial

RUN apt-get update && apt-get install -y \
		git \
		zip \
		xz-utils \
		curl \
		wget \
		php \
		php-cli \
		php-curl \
		php-gd \
		php-mysql \
		php-json \
		php-intl \
		php-mbstring \
		php-mcrypt \
		php-xml \
		mysql-client \
		apache2 \
		libapache2-mod-php \
	&& apt-get clean

COPY config/php.ini /usr/local/etc/php/

# Install
RUN a2enmod rewrite \
	&& php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush \
	&& chmod +x drush \
	&& mv drush /usr/local/bin \
	&& drush init -y \
	&& curl https://drupalconsole.com/installer -L -o drupal.phar \
	&& mv drupal.phar /usr/local/bin/drupal \
	&& chmod +x /usr/local/bin/drupal \
	&& drupal init --override \
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer \
    && wget https://github.com/bander2/twit/releases/download/1.1.0/twit-linux-amd64 -O /usr/local/bin/twit \
    && chmod u+x /usr/local/bin/twit

COPY config/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY config/dev.aliases.drushrc.php /root/.drush/dev.aliases.drushrc.php

WORKDIR /var/www/drupal

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
