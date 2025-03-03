## ************************************************************************** //
##                              Redis Dockerfile                              //
## ************************************************************************** //

# Define Base Image for Docker to build with
FROM debian:bullseye

# Install Dependencies
RUN apt update && apt upgrade -y
RUN apt-get install -y redis-server

# Copy custom Entrypoint bash script
COPY ./tools/entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Set Entrypoint
ENTRYPOINT [ "redis-server", "--protected-mode", "no" ]

