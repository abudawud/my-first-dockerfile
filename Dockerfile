FROM php:5.6-apache

LABEL Description="Apache and php5.6 with pdo_oci included + self signed ssl" \
	Maintener="abudawud<warishafidz@gmail.com>" \
	License="GNU GPLv2" \
	Verson="1.0"

# Update package
RUN apt-get update

RUN set -eux; \
	# generate ssl certificate
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/apache-selfsigned.key \
		-out /etc/ssl/certs/apache-selfsigned.crt \
		-subj "/C=ID/ST=Jatim/L=Pasuruan/O=PLTGU Grati/CN=izinkerja.indonesiapower.co.id"; \
	# replace apache certificae with generated one
	sed -ri 's/ssl-cert-snakeoil.pem/apache-selfsigned.crt/; s/ssl-cert-snakeoil.key/apache-selfsigned.key/' \
		/etc/apache2/sites-available/default-ssl.conf

# Enable module and site
RUN set -eux; \
	a2enmod ssl; \
	a2ensite default-ssl

# Enable php.ini configuration and do some config
RUN set -eux; \
	mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini; \
	# set curl.cainfo for cert
	sed -ri 's/;curl.cainfo =/curl.cainfo=\/etc\/ssl\/certs\/apache-selfsigned.crt/' /usr/local/etc/php/php.ini

# Setup oracle instant client
RUN mkdir /opt/oracle
COPY instantclient-basic-linux.x64-11.2.0.4.0.zip /opt/oracle
COPY instantclient-sdk-linux.x64-11.2.0.4.0.zip /opt/oracle

# Setup instantclient
RUN set -eux;\
	cd /opt/oracle; \
	apt-get install -y unzip libaio1; \
	unzip instantclient-basic-linux.x64-11.2.0.4.0.zip; \
	unzip instantclient-sdk-linux.x64-11.2.0.4.0.zip; \
	sh -c "echo /opt/oracle/instantclient_11_2 > \
      /etc/ld.so.conf.d/oracle-instantclient.conf"; \
	ldconfig; \
	cd instantclient_11_2; \
	ln -s libclntsh.so.11.1 libclntsh.so

# Download php source and setup pdo_oci
RUN set -eux; \
	apt-get install -y wget; \
	mkdir /opt/src && cd /opt/src; \
	# download and extract
	wget https://www.php.net/distributions/php-5.6.40.tar.gz; \
	tar xzf php-5.6.40.tar.gz; \
	cd php-5.6.40/ext/pdo_oci; \
	# configure and make pdo_oci
	phpize; \
	./configure --with-pdo-oci=instantclient,/opt/oracle/instantclient_11_2,11.2; \
	make; \
	make install; \
	# enable extension
	sed -ri 's/;extension=php_pdo_oci.dll/extension=pdo_oci.so/' /usr/local/etc/php/php.ini
