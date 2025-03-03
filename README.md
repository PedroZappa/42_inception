<a name="readme-top"></a>
<div align="center">

# 42_Inception

> This document is a System Administration related exercise.

<p>
    <img src="https://img.shields.io/badge/score-%20%2F%2100-success?style=for-the-badge" />
    <img src="https://img.shields.io/github/repo-size/PedroZappa/42_inception?style=for-the-badge&logo=github">
    <img src="https://img.shields.io/github/languages/count/PedroZappa/42_inception?style=for-the-badge&logo=" />
    <img src="https://img.shields.io/github/languages/top/PedroZappa/42_inception?style=for-the-badge" />
    <img src="https://img.shields.io/github/last-commit/PedroZappa/42_inception?style=for-the-badge" />
</p>

___

<h3>Table o'Contents</h3>

</div>

<!-- mtoc-start -->

  * [About 📌](#about-)
  * [Services Overview](#services-overview)
    * [Dockerfile specification](#dockerfile-specification)
      * [MariaDB Docker](#mariadb-docker)
      * [Nginx Docker](#nginx-docker)
      * [WordPress Docker](#wordpress-docker)
    * [Docker Compose Specification](#docker-compose-specification)
      * [Network](#network)
      * [Services ](#services-)
        * [`MariaDB`](#mariadb)
        * [`WordPress`](#wordpress)
        * [`Nginx`](#nginx)
      * [Persistent Volumes](#persistent-volumes)
    * [Secrets Management](#secrets-management)
  * [Usage 🏁](#usage-)
* [Docker Glossary 📖](#docker-glossary-)
* [References 📚](#references-)
* [License 📖](#license-)

<!-- mtoc-end -->


___

## About 📌

The present documentation provides an overview of the 42 Inception project.

The `Inception` project configures a containerized environment using `Docker` for deploying a secure `WordPress` website with `MariaDB` as a database and `Nginx` as the web server.

This document provides a programatical approach to setting up and running a container network efficiently.

___

## Services Overview

This `Inception` implementation sdets up a multi-container environment with the following services:

- **MariaDB**: A relational database management system (RDBMS) for storing and managing structured data.
- **WordPress**: An open-source web content management system (CMS) for creating and managing websites.
- **Nginx**: A high-performance web server for serving static and dynamic content over the internet.

Every service is configured to work in tandem using `Docker Compose`, with a secure mechanism to manage secrets.

### Dockerfile specification

#### MariaDB Docker
> Relational database system; Persistent storage for `WordPress`. 

- **Base Image**: `debian:bullseye`
- **Dependencies**:
    - `wget`, `curl` for download support.
    - `gnupg` cryptographic tool for encryption and data signing support.
    - `libaio1` for asynchronous I/O support.
    - `mariadb-server` for MariaDB server.
    - `mariadb-client` for MariaDB client.
- **Volumes**: `/var/lib/mysql` for persistent data storage.
- **Entrypoint**: Custom bash script for database initialization and secret encryption.
- **@ Port**: `3306`

#### Nginx Docker
> Reverse proxy server for serving WordPress content securely.

- **Base Image**: `debian:bullseye`
- **Dependencies**:
    - `nginx`, for serving static and dynamic content.
    - `openssl`, for generating `SSL` certificates for `HTTPS`.
- **Config**: Custom Nginx configuration file (`passunca42pt.conf`), moved tto `etc/nginx/siters-available`.
- **Entrypoint**: Custom bash script for SSL certificate generation and Nginx server initialization.
- **@ Port**: `443` (HTTPS).


#### WordPress Docker
> Content Management System (`CMS`) configured to connect to `MariaDB`.

- **Base Image**: `debian:bullseye`
- **Dependencies**:
    - `php-mysqli` provides support for  `MySQL` database connnections in `PHP`.
    - `php-fpm` provides support for asynchronous execution of PHP improving performance (`FastCGI`).
    - `mysql-client` tools. 
- **Volumes**: `/var/www/html/wordpress` for persistent WordPress data storage.
- **Entrypoint**: Custom bash script for configuring `WordPress`, decrypting secrets and running `FastCGI`.

___

### Docker Compose Specification

#### Network

- `inception`: **Bridge Network** for inter-container communication.

#### Services 

##### `MariaDB`

- **Build Context**: `./requirements/mariadb`
- **Container Name**: `mariadb`
- **Secrets**: `secret_key` and encrypted secrets.
- **Volumes**: `db_data` for persistent database storage.
- **@ Port**: `3306`

##### `WordPress`

- **Build Context**: `./requirements/wordpress`
- **Container Name**: `wordpress`
- **Dependencies**: 
    -`MariaDB`
- **Secrets**: `secret_key` and encrypted secrets.
- **Volumes**: `wp_data` for persistent WordPress data storage.
- **@ Port**: `9000`

##### `Nginx`

- **Build Context**: `./requirements/nginx`
- **Container Name**: 
    - `nginx`
- **Dependencies**: Requires WordPress.
- **Volumes**: `wp_data` for serving WordPress data.
- **@ Port**: `443`

#### Persistent Volumes

- `db_data`: for persistent `MariaDB` database storage.
    - **Path**: `/home/passunca/data/db`
- `wp_data`: for persistent `WordPress` content storage.
    - **Path**: `/home/passunca/data/wp`

___

### Secrets Management

- **Encrypted Secrets**: are stored in the `secrets.enc` and decrypted at runtime by `Nginx` using `openssl`.
```sh
# Encrypt secrets file using AES-256 encryption with PBKDF2 key derivation
openssl enc -aes-256-cbc -salt -pbkdf2 -in secrets.txt -out secrets.enc -pass pass:$(cat decryptkey.txt)

# Decrypt secrets file at runtime using the secret key
openssl enc -aes-256-cbc -d -pbkdf2 -in /run/secrets/secrets.enc -out /run/secrets/secrets.txt -pass pass:$(cat /run/secrets/secret_key)
```

___

## Usage 🏁

1. Clone the repository:
```bash
git clone https://github.com/PedroZappa/42_inception.git
cd 42_inception
```
2. Setup .env and secrets:
    - `secrets.txt`:
```sh
db_password=dbpassword
db_root_password=dbrootpassword
wp_admin_password=wpapassword
wp_admin_email=passunca@student.42porto.com
wp_user_password=wpupassword
wp_user_email=pedrogzappa@gmail.com
ftp_password=ftppassword

```
    - `.env`:
```sh
USER=passunca
DOMAIN_NAME=${USER}.42.fr
WWWLOCAL=/var/www/html/

# SSL Certificates
CERTS_=/etc/nginx/ssl/${USER}.crt

# MySQL
MYSQL_DATABASE=mariadb_db
MYSQL_USER=user
MYSQL_HOST=mariadb

# WordPress
WP_ADMIN=wpa
WP_USER=wpu

# FTP
FTP_USER=ftpuser

# IRC

```

3. Build the Docker images:
```bash
docker-compose build
```
4. Run containers:
```bash
docker-compose up -d
```


___
# Docker Glossary 📖

- [Docker GLOSS.md](GLOSS.md)

# References 📚

- [Docker Docs](https://docs.docker.com/)

# License 📖

This work is published under the terms of <a href="https://github.com/PedroZappa/42_minishell/blob/main/LICENSE">42 Unlicense</a>.

<p align="right">(<a href="#readme-top">get to top</a>)</p>

