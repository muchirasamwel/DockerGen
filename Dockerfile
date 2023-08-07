FROM php:7.1-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

# Install system dependencies
RUN install-php-extensions zip

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - 

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer


# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    mkdir -p /home/$user/.ssh && \
    chown -R $user:$user /home/$user

RUN docker-php-ext-install sockets

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Set working directory
WORKDIR /app
USER $user

# CMD ["composer","install","--ignore-platform-reqs"]
# CMD [ "composer","dump-autoload" ]
# RUN npm install

