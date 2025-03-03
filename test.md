# Inception Project Setup Guide

## Overview

The Inception project configures a containerized environment using Docker for deploying a secure WordPress website with MariaDB as the database and Nginx as the web server. This guide provides a structured approach to setting up and running the project efficiently.

## Services Overview

### 1. MariaDB

- Relational database system.
- Persistent storage for WordPress.
- Runs inside a Docker container with encrypted secrets management.

### 2. WordPress

- Content management system (CMS).
- Configured to connect securely to MariaDB.
- Runs on PHP with FastCGI Process Manager (PHP-FPM).

### 3. Nginx

- Reverse proxy and web server.
- Handles HTTPS with SSL certificates.
- Serves WordPress content securely.

---

## Docker Setup

### 1. MariaDB Dockerfile

- **Base Image**: `debian:bullseye`
- **Installed Packages**:
  - `mariadb-server`, `mariadb-client`
  - `gnupg`: Used for secure key management and package verification.
  - `libaio1`: Provides asynchronous I/O support required by MariaDB.
- **Entrypoint**:
  - Decrypts database credentials using OpenSSL.
  - Initializes MariaDB and configures authentication.
- **Ports & Volumes**:
  - Exposes `3306` for database connections.
  - Uses `/var/lib/mysql` for persistent data.

### 2. WordPress Dockerfile

- **Base Image**: `debian:bullseye`
- **Installed Packages**:
  - `php-fpm`: PHP FastCGI Process Manager for handling PHP requests efficiently.
  - `php-mysqli`: PHP extension for MySQL database connections.
  - `mysql-client`: Provides MySQL command-line tools for database interaction.
  - `wp-cli`: Command-line tool for managing WordPress installations.
- **Entrypoint**:
  - Decrypts credentials securely.
  - Sets up `wp-config.php` with database credentials.
  - Installs and configures WordPress.
- **Volumes**:
  - `/var/www/html/wordpress` for persistent website data.

### 3. Nginx Dockerfile

- **Base Image**: `debian:bullseye`
- **Installed Packages**:
  - `nginx`: Web server and reverse proxy.
  - `openssl`: Used for generating and managing SSL certificates.
- **Entrypoint**:
  - Generates SSL certificates.
  - Starts Nginx with custom configuration.
- **Ports & Volumes**:
  - Exposes `443` for HTTPS traffic.
  - Config file stored in `/etc/nginx/sites-available`.

---

## Docker Compose Configuration

### Service Definitions

#### 1. MariaDB

- **Context**: `./requirements/mariadb`
- **Container Name**: `mariadb`
- **Exposed Ports**: `3306`
- **Volumes**: `db_data:/var/lib/mysql`

#### 2. WordPress

- **Context**: `./requirements/wordpress`
- **Container Name**: `wordpress`
- **Exposed Ports**: `9000`
- **Dependencies**: Requires MariaDB.
- **Volumes**: `wp_data:/var/www/html`

#### 3. Nginx

- **Context**: `./requirements/nginx`
- **Container Name**: `nginx`
- **Exposed Ports**: `443:443`
- **Dependencies**: Requires WordPress.
- **Volumes**: `wp_data:/var/www/html`

### Secrets Management

- **Encrypted Secrets File**: `secrets.enc`
- **Encryption & Decryption**:
  ```bash
  # Encrypt secrets.txt using AES-256-CBC encryption
  openssl enc -aes-256-cbc -salt -pbkdf2 -in secrets.txt -out secrets.enc -pass pass:$(cat decryptkey.txt)
  
  # Decrypt secrets.enc at runtime to retrieve credentials
  openssl enc -aes-256-cbc -d -pbkdf2 -in /run/secrets/secrets.enc -out /run/secrets/secrets.txt -pass pass:$(cat /run/secrets/secret_key)
  ```

---

## Docker Glossary

### Image Management

- `docker pull [image]` - Download an image from a registry.
- `docker images` - List all local images.
- `docker rmi [image]` - Remove an image.
- `docker build -t [name:tag] .` - Build an image from a Dockerfile.

### Container Lifecycle

- `docker run [options] [image]` - Create and start a container.
- `docker start [container]` - Start a stopped container.
- `docker stop [container]` - Stop a running container.
- `docker restart [container]` - Restart a container.
- `docker rm [container]` - Remove a container.

### Container Operations

- `docker ps` - List running containers.
- `docker ps -a` - List all containers (including stopped ones).
- `docker logs [container]` - View container logs.
- `docker exec -it [container] [command]` - Run a command in a running container.
- `docker cp [container]:[path] [local-path]` - Copy files from container to host.

### Volumes and Networks

- `docker volume ls` - List volumes.
- `docker volume create [name]` - Create a volume.
- `docker network ls` - List networks.
- `docker network create [name]` - Create a network.

### Docker Compose

- `docker-compose up` - Create and start containers defined in `docker-compose.yml`.
- `docker-compose down` - Stop and remove containers defined in `docker-compose.yml`.
- `docker-compose build` - Build or rebuild services.

### System

- `docker info` - Display system-wide information.
- `docker system prune` - Remove unused data (containers, networks, images).

---

## Volumes & Networks

- **Persistent Volumes**:
  - `db_data`: Stores MariaDB database files.
  - `wp_data`: Stores WordPress content.
- **Custom Network**: `inception_net` for inter-container communication.

---

## Deployment Guide

### 1. Build the Images

```bash
docker-compose build
```

### 2. Start the Containers

```bash
docker-compose up -d
```

### 3. Verify the Setup

- **Database**: Ensure MariaDB is running and accessible.
- **WordPress**: Confirm site setup and functionality.
- **Nginx**: Validate HTTPS and SSL certificates.

---

## Security Considerations

- **Encrypted Secrets**: Prevents exposure of sensitive credentials.
- **SSL Certificates**: Ensures encrypted communication.
- **Isolated Network**: Enhances security by restricting container access.

---

## Conclusion

This setup ensures a scalable and secure deployment of WordPress using Docker containers, with MariaDB for database management and Nginx for web serving. By leveraging encrypted secrets and SSL, the system maintains high security standards while enabling ease of deployment and management.


