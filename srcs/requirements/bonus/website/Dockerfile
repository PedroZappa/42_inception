# **************************************************************************** #
#                              Website Dockerfile                              #
# **************************************************************************** #

FROM debian:bullseye

# Install Nginx and clean up apt cache
RUN apt-get update && apt-get install -y nginx && \ 
    rm -rf /var/lib/apt/lists/*

# Copy a HTML file into the container
COPY site/ /var/www/html/

# Copy the entrypoint script
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 80 (HTTP)
EXPOSE 80

# Set the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

