FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

COPY ./oracle-client /tmp
COPY ./queue-laravel.conf /etc/supervisor/conf.d/queue-laravel.conf

#Update composer script helper
COPY /bin/update /bin/update
RUN chmod +x /bin/update

#Refresh users script
COPY /bin/refresh_users /bin/refresh_users
RUN chmod +x /bin/refresh_users

#Setup script
COPY /bin/setup /bin/setup
RUN chmod +x /bin/setup

#Test command
COPY /bin/dusk /bin/dusk
RUN chmod +x /bin/dusk

#UnitTest command
COPY /bin/unit /bin/unit
RUN chmod +x /bin/unit

#Magical command
COPY /bin/fix /bin/fix
RUN chmod +x /bin/fix

#Code analysis command
COPY /bin/code_analysis /bin/code_analysis
RUN chmod +x /bin/code_analysis

#Code stats command
COPY /bin/code_stats /bin/code_stats
RUN chmod +x /bin/code_stats

#Code copy paste detector command
COPY /bin/copy_paste_detector /bin/copy_paste_detector
RUN chmod +x /bin/copy_paste_detector

#Security checker command
COPY /bin/security_checker /bin/security_checker
RUN chmod +x /bin/security_checker

#Php code sniffer command
COPY /bin/php_code_sniffer /bin/php_code_sniffer
RUN chmod +x /bin/php_code_sniffer

RUN apt-get update -yqq && apt-get install -yq --no-install-recommends \
    apt-utils \
    apt-transport-https \
    curl \
    gnupg2 \
    wget \
    # Install git
    git \
    # Install apache
    apache2 \
    # Install php 7.2
    php7.2 \
    libapache2-mod-php7.2 \
    php7.2-cli \
    php7.2-json \
    php7.2-curl \
    php7.2-fpm \
    php7.2-dev \
    php7.2-gd \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-bcmath \
    php7.2-mysql \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-zip \
    php7.2-intl \
    php-imagick \
    libldap2-dev \
    libaio1 \
    libaio-dev \
    # Install tools
    openssl \
    nano \
    graphicsmagick \
    imagemagick \
    ghostscript \
    iputils-ping \
    locales \
    rlwrap \
    php-pear \
    make \
    supervisor \
    cmake \
    unzip \
    zip \
    gzip \
    tar \
    ca-certificates \
    && apt-get clean

# Install Oracle Client
RUN cd /opt &&\
    mkdir oracle &&\
    mv /tmp/instantclient* /opt/oracle/ &&\
    cd /opt/oracle/ &&\
    unzip instantclient-basic-linux.x64-12.2.0.1.0.zip &&\
    unzip instantclient-sqlplus-linux.x64-12.2.0.1.0.zip &&\
    unzip instantclient-sdk-linux.x64-12.2.0.1.0.zip &&\
    cd /opt/oracle/instantclient_12_2/ &&\
    ln -s libclntsh.so.12.1 libclntsh.so &&\
    echo "/opt/oracle/instantclient_12_2/" >> /etc/ld.so.conf.d/oracle.conf &&\
    ldconfig &&\
    echo 'export ORACLE_HOME=/opt/oracle' >> ~/.bashrc &&\
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/oracle/instantclient_12_2' >> ~/.bashrc &&\
    echo 'PATH=$PATH:/opt/oracle/instantclient_12_2' >> ~/.bashrc &&\
    echo "alias sqlplus='/usr/bin/rlwrap -m /opt/oracle/instantclient_12_2/sqlplus'" >> ~/.bashrc &&\
    cd /opt/oracle &&\
    pecl download oci8 &&\
    tar -xzvf oci8*.tgz &&\
    cd oci8-2.2.0 &&\
    phpize &&\
    ./configure --with-oci8=instantclient,/opt/oracle/instantclient_12_2/ &&\
    make install &&\
    echo 'instantclient,/opt/oracle/instantclient_12_2' | pecl install oci8 \
    service supervisor restart \
    supervisorctl reread \
    supervisorctl update \
    supervisorctl start queue-laravel:* 

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8

# Configure PHP for My Site
COPY my-site.ini /etc/php/7.2/mods-available/
RUN phpenmod my-site

# Configure apache for My Site
RUN a2enmod rewrite expires
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

# Configure vhost for My Site
COPY my-site.conf /etc/apache2/sites-available/
RUN a2dissite 000-default
RUN a2ensite my-site.conf

#Configure Https
RUN a2enmod ssl
COPY default-ssl.conf /etc/apache2/sites-available/
RUN a2ensite default-ssl.conf

#Create user dgi
RUN useradd -u 1000 dgi

#Create user gitlab-runner
RUN useradd -u 1003 gitlab-runner

EXPOSE 80 443

WORKDIR /var/www/

CMD apachectl -D FOREGROUND