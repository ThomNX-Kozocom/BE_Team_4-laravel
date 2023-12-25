FROM php:8.2.3-apache

COPY ./php.ini /usr/local/etc/php/conf.d

ENV APACHE_DOCUMENT_ROOT /home/webservice/mietaro/public

ARG AUTH_BASIC_USERNAME
ARG AUTH_BASIC_PASSWORD
ARG AUTH_BASIC_ENABLE

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
# RUN htpasswd -b -c /etc/apache2/.htpasswd ${AUTH_BASIC_USERNAME} ${AUTH_BASIC_PASSWORD}
RUN if [ ${AUTH_BASIC_ENABLE} = true ]; then htpasswd -b -c /etc/apache2/.htpasswd ${AUTH_BASIC_USERNAME} ${AUTH_BASIC_PASSWORD} ;fi

COPY ./enudge.conf /etc/apache2/sites-available
RUN echo 'LogFormat "%{X-Forwarded-For}i %{X-Forwarded-Proto}i %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined' >> /etc/apache2/apache2.conf

# RUN apt-get update \
#   && apt-get install -y cron wget busybox-static zlib1g-dev libzip-dev libbz2-dev libmemcached-dev libpq-dev libmcrypt-dev libsqlite3-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxml2-dev libgmp-dev python3 python3-pip unzip git vim curl wkhtmltopdf fonts-ipafont default-mysql-client-core dnsutils libatlas3-base libatlas-base-dev gfortran \
#   && pecl install apcu igbinary mcrypt xmlrpc-1.0.0RC3 opcache \
#   && docker-php-ext-enable apcu igbinary mcrypt xmlrpc opcache \
#   && docker-php-ext-install bz2 calendar exif gettext pdo_mysql pdo_pgsql zip \
#   && docker-php-ext-install gmp mysqli pcntl shmop sockets sysvmsg sysvsem sysvshm \
#   && docker-php-aext-configure gd --with-freetype --with-jpeg \
#   && docker-php-ext-install -j$(nproc) gd 

# RUN fc-cache -fv

# # polyfit:run用
# RUN pip3 install numpy scipy

# RUN git clone -b release/5.3.6 https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis && \
#     docker-php-ext-install redis

# # Install composer and add its bin to the PATH.
# # マルチステージビルドを採用
# COPY --from=composer:1.10.15 /usr/bin/composer /usr/bin/composer

# # Let's encrypt の中間証明書インストール・反映
# WORKDIR /usr/share/ca-certificates
# RUN wget https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt
# RUN echo lets-encrypt-x3-cross-signed.pem.txt >> /etc/ca-certificates.conf
# RUN update-ca-certificates

WORKDIR /home/webservice/mietaro
COPY . /home/webservice/mietaro

RUN chmod 777 -R storage
RUN chmod 777 -R bootstrap/cache

RUN a2enmod rewrite
#CMD service apache2 restart

# RUN composer install

