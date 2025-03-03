# Docker Glossary

## Image Management

- `docker pull [image]` - Download an image from a registry.
- `docker images` - List all local images.
- `docker rmi [image]` - Remove an image.
- `docker build -t [name:tag] .` - Build an image from a Dockerfile.

## Container Lifecycle

- `docker run [options] [image]` - Create and start a container.
- `docker start [container]` - Start a stopped container.
- `docker stop [container]` - Stop a running container.
- `docker restart [container]` - Restart a container.
- `docker rm [container]` - Remove a container.

## Container Operations

- `docker ps` - List running containers.
- `docker ps -a` - List all containers (including stopped ones).
- `docker logs [container]` - View container logs.
- `docker exec -it [container] [command]` - Run a command in a running container.
- `docker cp [container]:[path] [local-path]` - Copy files from container to host.

## Volumes and Networks

- `docker volume ls` - List volumes.
- `docker volume create [name]` - Create a volume.
- `docker network ls` - List networks.
- `docker network create [name]` - Create a network.

## Docker Compose

- `docker-compose up` - Create and start containers defined in `docker-compose.yml`.
- `docker-compose down` - Stop and remove containers defined in `docker-compose.yml`.
- `docker-compose build` - Build or rebuild services.

## System

- `docker info` - Display system-wide information.
- `docker system prune` - Remove unused data (containers, networks, images).
