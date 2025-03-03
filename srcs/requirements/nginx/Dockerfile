# ************************************************************************** //
#                              Nginx Dockerfile                              //
# ************************************************************************** //

# Define Base Image for Docker to build with
FROM debian:bullseye

# Install Dependencies
RUN apt update && apt upgrade -y
RUN apt-get install -y \
  nginx \
  openssl \
  curl

# Load Wordpress website to Nginx container
COPY ./conf/nginx.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/

# Copy custom Entrypoint bash script
COPY ./tools/entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Set Entrypoint
ENTRYPOINT [ "sh", "/entrypoint.sh" ]
