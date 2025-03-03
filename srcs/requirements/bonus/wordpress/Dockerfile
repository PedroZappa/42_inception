## ************************************************************************** //
##                            WordPress Dockerfile                            //
## ************************************************************************** //

# Define Base Image for Docker to build with
FROM debian:bullseye

# Install Dependencies
RUN apt-get update && apt upgrade -y && \
    apt-get install -y wget php-mysqli php-fpm && \
    apt-get install -y redis-server php-redis
RUN apt-get install -y default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy custom Entrypoint bash script
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["sh", "entrypoint.sh"]

