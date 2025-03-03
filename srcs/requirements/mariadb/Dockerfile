## ************************************************************************** //
##                             MariaDB Dockerfile                             //
## ************************************************************************** //

# Define Base Image for Docker to build with
FROM debian:bullseye

# Install Dependencies
RUN apt-get update && apt-get install -y \
  wget \
  curl \
  gnupg \
  libaio1 && \
  rm -fr /var/lib/apt/lists/*

# Get MariaDB repository and Install 
RUN wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup && \
  bash mariadb_repo_setup --mariadb-server-version=10.5 && \
  apt-get update && apt-get install -y \
  mariadb-server \
  mariadb-client && \
  rm -fr /var/lib/apt/lists/*

# Copy custom Entrypoint bash script
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Remove default mariadb configuration
RUN rm /etc/mysql/mariadb.conf.d/50-server.cnf
# Move custom configuration into place
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d

# Export Port and Volume
EXPOSE 3306
VOLUME ["/var/lib/mysql"]

# Set Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
