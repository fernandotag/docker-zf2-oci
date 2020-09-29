FROM php:5.6-apache

RUN apt-get update && apt-get install     -qqy git unzip libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \ 
        zlib1g-dev libicu-dev g++ \
        libaio1 wget && apt-get clean autoclean && apt-get autoremove --yes &&  rm -rf /var/lib/{apt,dpkg,cache,log}/ 

#composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ORACLE oci 
RUN mkdir /opt/oracle \
    && cd /opt/oracle     
    
ADD oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip /opt/oracle
ADD oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip /opt/oracle

# Install Oracle Instantclient
RUN  unzip /opt/oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && ln -s /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so \
    && ln -s /opt/oracle/instantclient_12_1/libclntshcore.so.12.1 /opt/oracle/instantclient_12_1/libclntshcore.so \
    && ln -s /opt/oracle/instantclient_12_1/libocci.so.12.1 /opt/oracle/instantclient_12_1/libocci.so \
    && rm -rf /opt/oracle/*.zip
    
ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_12_1:${LD_LIBRARY_PATH}

# Install Oracle extensions
RUN echo 'instantclient,/opt/oracle/instantclient_12_1/' | pecl install oci8-2.0.12 \ 
       && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_12_1,12.1 \
       && docker-php-ext-install \
       			mysql \
            mysqli \
	          pdo_mysql \
	          pdo_oci \
            intl \
            gd \
      && docker-php-ext-enable \
            oci8 \ 
            pdo_oci \
            pdo_mysql 

RUN echo 'date.timezone = "America/Sao_Paulo"' > /usr/local/etc/php/conf.d/timezone.ini

# Enable Apache2 modules
RUN a2enmod rewrite

# Set up the Apache2 environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /zf2-app

# adding assets
ADD assets/ /assets/

ENTRYPOINT ["/assets/entrypoint.sh"]

EXPOSE 80


