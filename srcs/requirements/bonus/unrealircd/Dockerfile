
## ************************************************************************** //
##                           UnrealIRCd Dockerfile                            //
## ************************************************************************** //

FROM debian:bullseye

# Create a new user to avoid running as root
RUN useradd -m unrealircd_user

# Install Dependencies
RUN apt-get update && apt upgrade -y && \
  apt-get install -y build-essential pkg-config gdb libssl-dev libpcre2-dev \
  libargon2-0-dev libsodium-dev libc-ares-dev libcurl4-openssl-dev wget \
  sudo automake libtool && \
  rm -rf /var/lib/apt/lists/*

# Set the UnrealIRCd version
ENV UNREALIRCD_VERSION 6.1.0

# Download and extract UnrealIRCd
RUN wget https://www.unrealircd.org/downloads/unrealircd-${UNREALIRCD_VERSION}.tar.gz && \
    tar xzvf unrealircd-${UNREALIRCD_VERSION}.tar.gz && \
    rm unrealircd-${UNREALIRCD_VERSION}.tar.gz

# Set working directory
WORKDIR /unrealircd-${UNREALIRCD_VERSION}

# Change ownership of the directory to the new user
RUN chown -R unrealircd_user:unrealircd_user /unrealircd-${UNREALIRCD_VERSION}

# Switch to the unrealircd user
USER unrealircd_user

# Run configuration and build as non-root user
RUN chmod +x ./Config && \
    ./Config && \
    make

# Install UnrealIRCd
RUN make install

# Create directories for certificates
RUN mkdir -p /home/unrealircd_user/unrealircd/conf/tls

# Generate SSL certificate and private key (Self-Signed)
# Generate private key
RUN openssl genpkey -algorithm RSA -out /home/unrealircd_user/unrealircd/conf/tls/server.key.pem \
      -pkeyopt rsa_keygen_bits:2048 && \
    # Generate certificate signing request (CSR)
    openssl req -new -key /home/unrealircd_user/unrealircd/conf/tls/server.key.pem \
      -out /home/unrealircd_user/unrealircd/conf/tls/server.csr \
      -subj "/C=PT/ST=Porto/L=Porto/O=ZedroCorp/OU=IT/CN=localhost" && \
    # Generate self-signed certificate
    openssl x509 -req -in /home/unrealircd_user/unrealircd/conf/tls/server.csr \
      -signkey /home/unrealircd_user/unrealircd/conf/tls/server.key.pem \
      -out /home/unrealircd_user/unrealircd/conf/tls/server.cert.pem -days 365 && \
    rm /home/unrealircd_user/unrealircd/conf/tls/server.csr

# Correct the cp command with absolute paths
COPY ./conf/unrealircd.conf /home/unrealircd_user/unrealircd/conf/unrealircd.conf

# Switch back to root to complete installation and final setup
USER root

# Expose IRC ports
EXPOSE 6660-6669 7000

# Copy custom Entrypoint bash script
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER unrealircd_user
  
# Set entrypoint
ENTRYPOINT ["sh", "/entrypoint.sh"]
