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

* [Docker Compose Files Overview](#docker-compose-files-overview)
* [Network Configuration](#network-configuration)
* [Secrets Management](#secrets-management)
  * [Secret Definition](#secret-definition)
  * [Security Implementation](#security-implementation)
  * [Service Integration Pattern](#service-integration-pattern)
  * [Rotation & Maintenance](#rotation--maintenance)
  * [Host Protection Measures](#host-protection-measures)
* [Volume Configuration](#volume-configuration)
* [Core Services Configuration](#core-services-configuration)
  * [MariaDB Service](#mariadb-service)
  * [WordPress Service](#wordpress-service)
  * [Nginx Service](#nginx-service)
* [Bonus Services Configuration](#bonus-services-configuration)
  * [Website Service](#website-service)
  * [Redis Service](#redis-service)
  * [Adminer Service](#adminer-service)
  * [UnrealIRCd Service](#unrealircd-service)
  * [Weechat Service](#weechat-service)
  * [Doom Service](#doom-service)
  * [Parrot Service](#parrot-service)
* [Notable Configuration Patterns](#notable-configuration-patterns)

<!-- mtoc-end -->

## Docker Compose Files Overview

The project includes two Docker Compose files:
- `docker-compose.yml`: Core services configuration
- `docker-compose_bonus.yml`: Extended configuration with additional services

## Network Configuration

Both compose files configure an `inception` bridge network for container communication, enabling isolated but interconnected services.

## Secrets Management

The infrastructure implements Docker secrets following security best practices[1][3][6], with additional hardening in the bonus configuration:

### Secret Definition
- `secret_enc`: Encrypted credentials vault at `~/secrets/vault/secrets.enc`
- `secret_key`: Decryption key stored separately at `~/secrets/vault/decryptionKey.txt`

### Security Implementation
- **Dual-Layer Encryption**: Secrets remain encrypted at rest and only decrypted in-memory within containers[1][9]
- **Runtime Protection**:
  - Secrets mounted as read-only files in `/run/secrets/`[3][6]
  - MariaDB service uses `secrets.enc:ro` mount for immutable access[2]
  - File mode restricted to 0444 (world-readable) by default[11]
- **Service Isolation**:
  - Core services only receive `secret_key`
  - Bonus services get additional `secret_enc` for extended security[4]

### Service Integration Pattern
Services access secrets through environment variables following the `_FILE` convention[1][3]:
```yaml
environment:
  MYSQL_ROOT_PASSWORD_FILE: /run/secrets/secrets.enc
```
This pattern:
1. Prefers file-based secret access over environment variables
2. Maintains compatibility with official images (MySQL, WordPress)
3. Prevents accidental logging of sensitive values[8]

### Rotation & Maintenance
- Key rotation requires recreating both `secret_enc` and `secret_key`
- Zero-downtime rotation procedure:
  1. Generate new key pair outside swarm
  2. Update compose files with new paths
  3. Redeploy services with `--secret-add` and `--secret-rm`[2][5]
- Secrets automatically revoked from stopped containers[6][9]

### Host Protection Measures
- Secrets directory (`~/secrets/vault/`) should have:
  - 700 permissions (owner-only access)
  - Encrypted filesystem (LUKS/dm-crypt)
  - Excluded from backups via `.dockerignore`[5][7]

___

## Volume Configuration

The project uses Docker volumes with bind mounts to ensure data persistence:

| Volume | Mount Path | Description |
|--------|------------|-------------|
| `db_data` | `~/data/db` | MariaDB database files |
| `wp_data` | `~/data/wp` | WordPress files |
| `ws_data` | `~/data/ws` | Static website files |
| `irc_data` | `~/data/irc` | IRC server data |
| `doom_data` | `~/data/doom` | Doom game data |

## Core Services Configuration

### MariaDB Service
- **Container**: `mariadb` built from custom Dockerfile
- **Image Tag**: `mariadb:42`
- **Health Checks**: Regular MySQL connectivity testing
- **Exposed Port**: 3306 (internal network only)
- **Restart Policy**: Up to 7 restart attempts on failure
- **Log Configuration**: JSON format with 7 files of 7MB max size each

### WordPress Service
- **Container**: `wordpress` with dependencies on MariaDB
- **Image Tag**: `wordpress:42`
- **Exposed Port**: 9000 (PHP-FPM)
- **Restart Policy**: Up to 7 restart attempts on failure
- **Dependencies**: Waits for MariaDB health check to pass

### Nginx Service
- **Container**: `nginx` with dependencies on WordPress
- **Image Tag**: `nginx:42`
- **Exposed Port**: 443 (HTTPS) mapped to host
- **Volumes**: Mounts WordPress files for serving content
- **Restart Policy**: Up to 7 restart attempts on failure

## Bonus Services Configuration

### Website Service
- **Container**: `website` for static content
- **Image Tag**: `website:42`
- **Volumes**: Mounts site content from host

### Redis Service
- **Container**: `redis` for caching
- **Image Tag**: `redis:42`
- **Exposed Port**: 6379
- **Health Checks**: Redis connectivity testing
- **Added in Bonus**: WordPress depends on Redis in the bonus configuration

### Adminer Service
- **Container**: `adminer` for database management
- **Image Tag**: `adminer:42`
- **Exposed Port**: 8080 mapped to host
- **Resource Limits**: 256MB memory limit

### UnrealIRCd Service
- **Container**: `unrealircd` IRC server
- **Image Tag**: `unrealircd:42`
- **Exposed Ports**: Multiple IRC ports (6660-6669, 6697, 6667, 7000)
- **Health Checks**: Network connectivity testing on port 6660

### Weechat Service
- **Container**: `weechat` IRC client
- **Image**: Uses existing `jess/weechat` image
- **Configuration**: Interactive TTY for user connection
- **Dependencies**: Starts after IRC server is running

### Doom Service
- **Container**: `doom` for running classic Doom game
- **Image Tag**: `doom:42`
- **Exposed Port**: 3333
- **Configuration**: Interactive TTY for game interaction

### Parrot Service
- **Container**: `parrot` (purpose unclear from configuration)
- **Image Tag**: `parrot:42`
- **Configuration**: Interactive TTY for user connection

## Notable Configuration Patterns

1. **Health Checking**: Services implement health checks to ensure dependencies are properly managed
2. **Logging Management**: Consistent JSON log format with rotation policies
3. **Resource Control**: Memory limits applied where appropriate
4. **Restart Policies**: Consistent policies for container reliability
5. **Volume Mounting**: Systematic approach to data persistence
6. **Secret Handling**: Secure credential management using Docker secrets

This Docker infrastructure demonstrates best practices for containerized application deployment with a focus on security, reliability, and maintainability.
