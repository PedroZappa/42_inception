# ************************************************************************** //
#                               FTP Dockerfile                               //
# ************************************************************************** //

FROM debian:bullseye

# Install vsftpd and other helper tools
RUN apt-get update && \
    apt-get install -y vsftpd openssl vim && \
    apt-get clean && \
    rm -fr /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/ftp/users /var/run/vsftpd/empty

# Load vsftpd configuration into container
COPY ./conf/vsftpd.conf /etc/vsftpd.conf
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 21 (FTP)
EXPOSE 21
EXPOSE 10000-10100

# Set the entrypoint script
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

# Run in the foreground (default)
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd.conf"]

