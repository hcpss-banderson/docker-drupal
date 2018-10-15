FROM ubuntu:bionic

RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update && apt-get install -y --no-install-recommends \
		git \
		zip \
		unzip \
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
		php-xml \
		php-apcu \
		libyaml-dev \
		php-dev \
		php-sqlite3 \
		mysql-client \
		apache2 \
		libapache2-mod-php \
		php-zip \
		openssl \
		ca-certificates \
		patch \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY config/php.ini /etc/php/7.2/apache2/
COPY config/php.ini /etc/php/7.2/cli/

RUN a2enmod rewrite

# Drush Launcher
RUN wget --no-check-certificate -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
	&& chmod +x drush.phar \
	&& mv drush.phar /usr/local/bin/drush

# Drupal Composer
RUN wget --no-check-certificate -O drupal.phar https://drupalconsole.com/installer \
	&& mv drupal.phar /usr/local/bin/drupal \
	&& chmod +x /usr/local/bin/drupal

# Composer
RUN php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer

COPY config/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY config/drupal.aliases.drushrc.php /root/.drush/drupal.aliases.drushrc.php

WORKDIR /var/www/drupal

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
