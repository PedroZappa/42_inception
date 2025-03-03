# ************************************************************************** //
#                            Wordpress Dockerfile                            //
# ************************************************************************** //

# Define Base Image for Docker to build with
FROM debian:bullseye

# Install Dependencies
RUN apt-get update && apt-get install -y
RUN apt-get install -y \
      wget php-mysqli php-fpm
# Install MySQL client healthcheck tools 
RUN apt-get install -y \
      default-mysql-client

# Move custom entrypoint script into container
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set Entrypoint
ENTRYPOINT ["sh", "entrypoint.sh"]
