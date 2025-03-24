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
    <img src="https://img.shields.io/coderabbit/prs/github/PedroZappa/42_inception?labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit%20Reviews" />
</p>


___

<h3>Table o'Contents</h3>

</div>


<!-- mtoc-start -->

* [Docker Compose Files Overview](#docker-compose-files-overview)
* [Network Configuration](#network-configuration)
* [Secrets Management](#secrets-management)
  * [Secret Definition & Sources](#secret-definition--sources)
  * [Security Implementation](#security-implementation)
  * [Service Integration Pattern](#service-integration-pattern)
  * [Access Control](#access-control)
  * [Rotation & Maintenance](#rotation--maintenance)
  * [Host Protection](#host-protection)
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
* [References](#references)
* [Study Articles](#study-articles)

<!-- mtoc-end -->

## Docker Compose Files Overview

The project includes two Docker Compose files:
- `docker-compose.yml`: Core services configuration
- `docker-compose_bonus.yml`: Extended configuration with additional services

## Network Configuration

Both compose files configure an `inception` bridge network for container communication, enabling isolated but interconnected services.

## Secrets Management

The infrastructure implements Docker secrets following security best practices[1][3][6], with defense-in-depth hardening across multiple layers:

### Secret Definition & Sources
```yaml
secrets:
  secret_enc:                     # Encrypted credentials vault
    file: ~/secrets/vault/secrets.enc
  secret_key:                     # Decryption key
    file: ~/secrets/vault/decryptionKey.txt
```
- **Immutable Storage**: Secrets remain encrypted at rest (AES-256)
- **Separation of Concerns**: Encryption key stored separately from encrypted payload
- **Path Conventions**:
  - `~/secrets/vault/`: Secret storage directory
  - `/run/secrets/`: Container mount point

### Security Implementation
- **Dual-Layer Encryption**:
  - At-rest: LUKS/dm-crypt encrypted host storage
  - In-transit: TLS between containers[1][6]
- **Runtime Protection**:
  - Read-only mounts with `:ro` suffix[3][6]
  - Memory-only decryption (no disk persistence)
  - File mode 0444 enforced (world-readable)
- **Service Isolation**:
  - Core services: `secret_key` only
  - Bonus services: `secret_key` + `secret_enc` for layered access[4]

### Service Integration Pattern
Services follow the `_FILE` convention for secret access[1][3]:
```yaml
environment:
  MYSQL_ROOT_PASSWORD_FILE: /run/secrets/secrets.enc
```
This implementation:
1. Prevents ENV variable leakage in logs[8]
2. Maintains compatibility with official images
3. Enables live rotation without container restarts

### Access Control
```yaml
secrets:
  - source: secret_key
    target: db_decryption_key
    uid: '999'       # MariaDB user
    gid: '999'
    mode: 0440
```
- **Principle of Least Privilege**:
  - Custom UID/GID mapping per service
  - Mode 0440 (owner/group readable) for sensitive secrets
- **Secret Scoping**:
  - DB secrets only available to DB-related services
  - Web secrets isolated to frontend services

### Rotation & Maintenance
- **Key Rotation Procedure**:
  1. Generate new key pair externally
  2. Update compose files with new paths
  3. Redeploy with `--secret-add`/`--secret-rm`[2][5]
- **Zero-Downtime Rotation**:
  - Phase 1: Add new secrets
  - Phase 2: Reload services (`SIGHUP`)
  - Phase 3: Remove old secrets
- **Automated Cleanup**:
  - Revoked secrets flushed from memory
  - Orphaned secrets garbage-collected[6]

### Host Protection
```bash
# Recommended directory setup
chmod 700 ~/secrets/vault
chown root:root ~/secrets/vault
mount -t tmpfs -o size=1M tmpfs ~/secrets/vault
```
- **Storage Requirements**:
  - tmpfs mount for in-memory operations
  - LUKS encryption for physical disks
  - Backup exclusion in `.dockerignore`[5][7]
- **Audit Trail**:
  - Secret access logging via auditd
  - Integrity checks with checksum verification

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
- **Container**: `doom` for running classic Doom game in your terminal
- **Image Tag**: `doom:42`
- **Exposed Port**: 3333
- **Configuration**: Interactive TTY for game interaction

### Parrot Service
- **Container**: `parrot` (for the lulz and the curlz)
- **Image Tag**: `parrot:42`
- **Configuration**: Interactive TTY for user connection

## Notable Configuration Patterns

1. **Health Checking**: Services implement health checks to ensure dependencies are properly managed
2. **Logging Management**: Consistent JSON log format with rotation policies
3. **Resource Control**: Memory limits applied where appropriate
4. **Restart Policies**: Consistent policies for container reliability
5. **Volume Mounting**: Systematic approach to data persistence
6. **Secret Handling**: Secure credential management using Docker secrets

___

## References

1. [Docker Security Best Practices: Cheat Sheet - GitGuardian Blog](https://blog.gitguardian.com/how-to-improve-your-docker-containers-security-cheat-sheet/)
2. [Docker Security Best Practices: A Complete Guide - Anchore](https://anchore.com/blog/docker-security-best-practices-a-complete-guide/)
3. [Security - Docker Docs](https://docs.docker.com/security/)
4. [21 Docker Security Best Practices: Daemon, Image, Containers - Spacelift](https://spacelift.io/blog/docker-security)
5. [Docker Security - OWASP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
6. [Top 20 Dockerfile best practices - Sysdig](https://sysdig.com/learn-cloud-native/dockerfile-best-practices/)
7. [Docker Engine security - Docker Docs](https://docs.docker.com/engine/security/)
8. [Building best practices - Docker Docs](https://docs.docker.com/build/building/best-practices/)

## Study Articles

* [Understanding Daemons in Computing Systems: From Concepts to Docker Implementation](https://www.perplexity.ai/page/understanding-daemons-in-compu-gCeFFp1RQZejr6w0VqHy7Q)

This Docker infrastructure demonstrates best practices for containerized application deployment with a focus on security, reliability, and maintainability.
