## ************************************************************************** //
##                             Parrot Dockerfile                             //
## ************************************************************************** //

FROM debian:bullseye

# Dependencies 
RUN apt-get update && apt-get install -y curl && \ 
    rm -rf /var/lib/apt/lists/*

# Copy the start script into the container
COPY tools/entrypoint.sh /entrypoint.sh

# Give execution permission to the script
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
