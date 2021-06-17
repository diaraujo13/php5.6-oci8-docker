FROM porchn/php5.6-apache

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libicu-dev \
        libmysqlclient18 \
        libc6 \
        libaio1 \
        zlib1g \
        make \
        libcurl4-gnutls-dev \
        unzip \
        libcurl4-gnutls-dev \
        libxml2-dev

RUN docker-php-ext-install  mysql mysqli 

# Install Postgre PDO
RUN apt-get install -y libpq5 libpq-dev unzip wget \
    && docker-php-ext-install  curl pdo 

# RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql     && docker-php-ext-install pgsql pdo_pgsql

RUN docker-php-ext-configure intl
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install intl pdo pdo_mysql mbstring xml soap  gd 
RUN docker-php-ext-install zip
RUN docker-php-ext-install gd

# ORACLE oci 
RUN install_dir="/opt/oracle"

RUN mkdir /opt/oracle \
    && cd /opt/oracle


# COPY ./.docker/oracle_client/instantclient-basic-linux.x64-11.2.0.3.0.zip -d  /opt/oracle
# COPY ./.docker/oracle_client/instantclient-sqlplus-linux.x64-11.2.0.3.0.zip -d /opt/oracle
# COPY ./.docker/oracle_client/instantclient-sdk-linux.x64-11.2.0.3.0.zip -d /opt/oracle
# COPY ./.docker/oracle_client/instantclient-jdbc-linux.x64-11.2.0.3.0.zip -d /opt/oracle
RUN wget https://raw.githubusercontent.com/sflyr/docker-sqlplus/15a2ad500c97a29571ff24330d4cbe13b648e424/instantclient-sdk-linux.x64-11.2.0.3.0.zip -P /opt/oracle
RUN wget https://raw.githubusercontent.com/sflyr/docker-sqlplus/15a2ad500c97a29571ff24330d4cbe13b648e424/instantclient-sqlplus-linux.x64-11.2.0.3.0.zip  -P /opt/oracle
RUN wget https://raw.githubusercontent.com/sflyr/docker-sqlplus/15a2ad500c97a29571ff24330d4cbe13b648e424/instantclient-jdbc-linux.x64-11.2.0.3.0.zip -P /opt/oracle
RUN wget https://raw.githubusercontent.com/sflyr/docker-sqlplus/fc9aa06c0da42cf8d20c226e4c293f3743bb675c/instantclient-basic-linux.x64-11.2.0.3.0.zip -P /opt/oracle

RUN ls /opt/oracle

RUN unzip "/opt/oracle/instantclient-*.zip" -d /opt/oracle
# RUN mv /opt/oracle/instantclient* /opt/oracle/instantclient_11_2

ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_11_2:${LD_LIBRARY_PATH}"
ENV PATH="/opt/oracle/instantclient_11_2:${PATH}"
ENV ORACLE_HOME="/opt/oracle/instantclient_11_2"

# Criação de links simbólicos (libclntshcore somente disponível a partir do 12.1 > )
RUN ln -s /opt/oracle/instantclient_11_2/libclntsh.so.11.1 /opt/oracle/instantclient_11_2/libclntsh.so \
    && ln -s /opt/oracle/instantclient_11_2/libocci.so.11.1 /opt/oracle/instantclient_11_2/libocci.so \
    && docker-php-ext-configure oci8 --with-oci8="instantclient,/opt/oracle/instantclient_11_2" \
    && docker-php-ext-install oci8 


# RUN pecl channel-update pecl.php.net

# RUN echo 'instantclient,/opt/oracle/instantclient_11_2' | pecl install oci8

# RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient_11_2
# RUN docker-php-ext-install pdo_oci
# RUN docker-php-ext-enable oci8

# Install Oracle extensions
# RUN docker-php-ext-install oci8 
# RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_11_2,11.2 
# RUN docker-php-ext-install pdo_oci 

RUN service apache2 restart
