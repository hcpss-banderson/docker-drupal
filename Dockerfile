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
		php-apcu \
		libyaml-dev \
		php-dev \
		php-sqlite3 \
		mysql-client \
		apache2 \
		libapache2-mod-php \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY config/php.ini /etc/php/7.0/apache/
COPY config/php.ini /etc/php/7.0/cli/

RUN a2enmod rewrite

# Drush
RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush \
	&& chmod +x drush \
	&& mv drush /usr/local/bin \
	&& drush init -y

# Drupal Composer
RUN curl https://drupalconsole.com/installer -L -o drupal.phar \
	&& mv drupal.phar /usr/local/bin/drupal \
	&& chmod +x /usr/local/bin/drupal

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer

COPY config/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY config/drupal.aliases.drushrc.php /root/.drush/drupal.aliases.drushrc.php

WORKDIR /var/www/drupal

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
