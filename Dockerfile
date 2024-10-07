# Use the official PHP 8.2 image with FPM
FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    vim \
    nginx \
    gzip \
    lsof \
    mariadb-client \
    default-mysql-client \
    sed \
    tar \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libicu-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    libcurl4-openssl-dev \
    curl \
    libmagickwand-dev \
    libssl-dev \
    libpcre3-dev \
    --no-install-recommends

# Install PHP extensions not included in the base image
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install intl \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install soap \
    && docker-php-ext-install sockets \
    && docker-php-ext-install xsl \
    && docker-php-ext-install zip

# Install and enable PECL extensions
RUN pecl install redis && docker-php-ext-enable redis \
    && pecl install imagick && docker-php-ext-enable imagick

# Modify the memory limit in the php.ini file
RUN sed -i 's/memory_limit = .*/memory_limit = 4G/' /usr/local/etc/php/php.ini-development \
&& cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# Install Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]