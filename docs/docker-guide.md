# Docker Beginner's Guide

## What is Docker?

Docker is a platform that allows you to package applications and their dependencies into isolated units called **containers**. Containers are lightweight, portable, and run consistently across different environments.

---

## Core Concepts

| Concept | Description |
|---------|-------------|
| **Image** | A read-only template with instructions for creating a container. Think of it as a blueprint. |
| **Container** | A running instance of an image. You can have multiple containers from the same image. |
| **Dockerfile** | A text file with instructions to build a Docker image. |
| **Volume** | Persistent storage that survives container restarts and removals. |
| **Network** | Allows containers to communicate with each other. |
| **Registry** | A repository for storing and distributing Docker images (e.g., Docker Hub). |

---

## Installation

### macOS
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Or use Homebrew:
brew install --cask docker
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER
# Log out and back in for this to take effect
```

### Verify Installation
```bash
docker --version
docker compose version
```

---

## Basic Docker Commands

### Working with Images

```bash
# Search for images on Docker Hub
docker search nginx

# Download an image
docker pull nginx
docker pull ubuntu:22.04    # With specific tag

# List downloaded images
docker images

# Remove an image
docker rmi nginx
docker rmi -f nginx         # Force remove

# Remove all unused images
docker image prune -a
```

### Working with Containers

```bash
# Run a container
docker run nginx

# Run in detached mode (background)
docker run -d nginx

# Run with a custom name
docker run -d --name my-nginx nginx

# Run with port mapping (host:container)
docker run -d -p 8080:80 nginx

# Run with environment variables
docker run -d -e MY_VAR=value nginx

# Run with volume mount
docker run -d -v /host/path:/container/path nginx

# Run interactively with terminal
docker run -it ubuntu bash

# Run and auto-remove when stopped
docker run --rm nginx

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop my-nginx

# Start a stopped container
docker start my-nginx

# Restart a container
docker restart my-nginx

# Remove a container
docker rm my-nginx
docker rm -f my-nginx       # Force remove running container

# Remove all stopped containers
docker container prune
```

### Docker Logs

```bash
# View container logs
docker logs my-nginx

# Follow logs in real-time
docker logs -f my-nginx

# Show last N lines
docker logs --tail 100 my-nginx

# Show logs with timestamps
docker logs -t my-nginx

# Combine options
docker logs -f --tail 50 -t my-nginx
```

### Docker Exec

```bash
# Execute a command in a running container
docker exec my-nginx ls /etc/nginx

# Open an interactive shell
docker exec -it my-nginx bash
docker exec -it my-nginx sh      # For Alpine-based images

# Run as specific user
docker exec -u root -it my-nginx bash

# Set environment variables
docker exec -e MY_VAR=value my-nginx env
```

### Inspect and Debug

```bash
# View container details
docker inspect my-nginx

# View container resource usage
docker stats
docker stats my-nginx

# View running processes in a container
docker top my-nginx

# Copy files between host and container
docker cp my-nginx:/etc/nginx/nginx.conf ./nginx.conf
docker cp ./myfile.txt my-nginx:/tmp/
```

---

## Dockerfile Basics

A Dockerfile defines how to build an image.

### Example: Node.js Application

```dockerfile
# Base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Command to run
CMD ["node", "server.js"]
```

### Example: Python Application

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

### Build and Run

```bash
# Build an image from Dockerfile
docker build -t myapp:1.0 .

# Build with different Dockerfile
docker build -f Dockerfile.dev -t myapp:dev .

# Build without cache
docker build --no-cache -t myapp:1.0 .
```

---

## Docker Compose

Docker Compose allows you to define and run multi-container applications using a YAML file.

### Example: docker-compose.yml

```yaml
version: "3.8"

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=database
    depends_on:
      - database
    volumes:
      - ./logs:/app/logs

  database:
    image: postgres:15
    environment:
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=myapp
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  db_data:
```

### Docker Compose Commands

```bash
# Start all services
docker compose up

# Start in detached mode
docker compose up -d

# Start specific service
docker compose up -d database

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v

# View running services
docker compose ps

# View logs
docker compose logs
docker compose logs -f web      # Follow specific service

# Execute command in service
docker compose exec web bash

# Rebuild images
docker compose build
docker compose up -d --build    # Rebuild and restart

# Scale a service
docker compose up -d --scale web=3

# Restart services
docker compose restart
docker compose restart web
```

---

## Volumes and Networks

### Volumes

```bash
# Create a volume
docker volume create mydata

# List volumes
docker volume ls

# Inspect a volume
docker volume inspect mydata

# Remove a volume
docker volume rm mydata

# Remove all unused volumes
docker volume prune

# Use volume in container
docker run -d -v mydata:/data nginx
```

### Networks

```bash
# Create a network
docker network create mynetwork

# List networks
docker network ls

# Inspect a network
docker network inspect mynetwork

# Connect container to network
docker network connect mynetwork my-nginx

# Disconnect from network
docker network disconnect mynetwork my-nginx

# Run container on specific network
docker run -d --network mynetwork nginx

# Remove network
docker network rm mynetwork
```

---

## Useful Command Combinations

```bash
# Stop all running containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Full cleanup (containers, images, volumes, networks)
docker system prune -a --volumes

# View disk usage
docker system df

# Export container as tar
docker export my-nginx > backup.tar

# Save image as tar
docker save myapp:1.0 > myapp.tar

# Load image from tar
docker load < myapp.tar
```

---

## Common Patterns

### Development with Hot Reload

```yaml
# docker-compose.dev.yml
version: "3.8"
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
```

Run with:
```bash
docker compose -f docker-compose.dev.yml up
```

### Using .dockerignore

Create a `.dockerignore` file to exclude files from the build context:

```
node_modules
.git
.env
*.log
Dockerfile
docker-compose.yml
.dockerignore
README.md
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `docker run -d -p 80:80 nginx` | Run container in background with port mapping |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker logs -f <container>` | Follow container logs |
| `docker exec -it <container> bash` | Open shell in container |
| `docker stop <container>` | Stop container |
| `docker rm <container>` | Remove container |
| `docker images` | List images |
| `docker rmi <image>` | Remove image |
| `docker build -t name:tag .` | Build image from Dockerfile |
| `docker compose up -d` | Start services in background |
| `docker compose down` | Stop and remove services |
| `docker compose logs -f` | Follow all service logs |
| `docker system prune -a` | Clean up unused resources |

---

## Next Steps

1. Practice building images for your own applications
2. Learn about multi-stage builds for smaller images
3. Explore Docker registries (Docker Hub, GitHub Container Registry)
4. Study container orchestration with Kubernetes or Docker Swarm
5. Learn about Docker security best practices
