# Dockerfile to spin up mediawiki 1.24.2 site that uses
# - nginx to serve requests
# - php5 with php-fpm with pooling
# - supervisor to manage server processes
# Technical points:
# - uses port 80 for web service
# - uses sqlite for database
# Includes LocalSettings.php and wiki.sqlite to bootstrap.

FROM	ubuntu:14.04
MAINTAINER Hugh Brown <hughdbrown@yahoo.com>

ENV MEDIAWIKI_VERSION 1.25
ENV MEDIAWIKI_FULL_VERSION 1.25.3
ENV MEDIAWIKI_TAR_GZ mediawiki-${MEDIAWIKI_FULL_VERSION}.tar.gz 

# Configure apt.
RUN	echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty universe' >> /etc/apt/sources.list
RUN	apt-get -y update

# Fix services that do not start in ubuntu.
# https://jpetazzo.github.io/2013/10/06/policy-rc-d-do-not-start-services-automatically/
# http://askubuntu.com/questions/365911/why-the-services-do-not-start-at-installation
RUN     sed -i 's/101/0/g' /usr/sbin/policy-rc.d

# Install prereqs.
RUN	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	apt-utils \
	ca-certificates \
	libreadline-dev net-tools curl wget

# Install server software.
RUN	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	supervisor \
	nginx-light \
	php5

# Install php5 packages.
RUN	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	php5-fpm \
	php5-apcu php5-gd php5-intl \
	php5-common php5-json \
	php5-sqlite

# Install gpg keys.
# I can't swear that this is necessary.
# https://www.mediawiki.org/keys/keys.txt
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
    441276E9CCD15F44F6D97D18C119E1A64D70938E \
    41B2ABE817ADD3E52BDA946F72BC1C5D23107F8A \
    162432D9E81C1C618B301EECEE1F663462D84F01 \
    1D98867E82982C8FE0ABC25F9B69B3109D3BB7B0 \
    3CEF8262806D3F0B6BA1DBDD7956EE477F901A30 \
    280DB7845A1DCAC92BB5A00A946B02565DC00AA7

# Add system service config.
ADD	conf/nginx.conf /etc/nginx/nginx.conf
ADD	conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD	conf/fpm.conf /etc/php5/fpm/php-fpm.conf
ADD	conf/fpm-pool-www.conf /etc/php5/fpm/pool.d/www.conf

# Install mediawiki.
ADD	http://download.wikimedia.org/mediawiki/${MEDIAWIKI_VERSION}/${MEDIAWIKI_TAR_GZ} /
RUN	mkdir /src && cd /src && \
	tar zxf /${MEDIAWIKI_TAR_GZ} && \
	ln -snf mediawiki-${MEDIAWIKI_FULL_VERSION} mediawiki && \
	mkdir -p /src/mediawiki/db && \
	chown -R www-data:www-data /src/mediawiki/

# Add startup script.
ADD	./mediawiki-start /usr/bin/mediawiki-start

# Expose nginx on port 80.
EXPOSE	80

# Use script to start supervisor to control server processes.
ENTRYPOINT	["/usr/bin/mediawiki-start"]

