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

## Hands-on Tutorial (Copy-Paste Ready)

This tutorial uses the example files from `examples/docker/`. All commands can be copied and pasted directly.

### Step 1: Set up the demo project

```bash
cd /tmp && mkdir flask-demo && cd flask-demo
```

```bash
cat > app.py << 'EOF'
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({'message': 'Hello from Flask in Docker!', 'status': 'running'})

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF
```

```bash
cat > requirements.txt << 'EOF'
flask==3.0.0
EOF
```

```bash
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
EOF
```

### Step 2: Build the image

```bash
docker build -t my-flask-image .
```

### Step 3: Run the container

```bash
docker run -d -p 5000:5000 --name flask-app my-flask-image
```

### Step 4: Test it works

```bash
curl http://localhost:5000
```

Expected output:
```json
{"message":"Hello from Flask in Docker!","status":"running"}
```

### Step 5: Try these commands (all will work now)

```bash
# List running containers
docker ps

# View container logs
docker logs flask-app

# Follow logs in real-time (Ctrl+C to exit)
docker logs -f flask-app

# Execute command inside container
docker exec flask-app ls /app

# Open interactive shell inside container
docker exec -it flask-app bash

# View container resource usage (Ctrl+C to exit)
docker stats flask-app

# Stop the container
docker stop flask-app

# Start it again
docker start flask-app

# Restart the container
docker restart flask-app
```

### Step 6: Clean up when done

```bash
docker stop flask-app && docker rm flask-app && docker rmi my-flask-image && rm -rf /tmp/flask-demo
```

---

## Basic Docker Commands (Using Public Images)

These commands use public images from Docker Hub - no build required.

### Working with Images

```bash
# Search for images on Docker Hub
docker search python

# Download an image
docker pull python:3.11-slim

# List downloaded images
docker images

# Remove an image
docker rmi python:3.11-slim

# Remove all unused images
docker image prune -a
```

### Running Containers (No Build Required)

```bash
# Run a simple command
docker run python:3.11-slim python --version

# Run interactively with terminal
docker run -it python:3.11-slim bash

# Run and auto-remove when stopped
docker run --rm python:3.11-slim python -c "print('Hello Docker!')"

# Run nginx web server (public image)
docker run -d -p 8080:80 --name my-nginx nginx

# Test nginx
curl http://localhost:8080

# Clean up nginx
docker stop my-nginx && docker rm my-nginx

# Run PostgreSQL database
docker run -d -p 5432:5432 --name my-postgres -e POSTGRES_PASSWORD=secret postgres:15

# Clean up postgres
docker stop my-postgres && docker rm my-postgres
```

### Container Lifecycle

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop <container-name>

# Start a stopped container
docker start <container-name>

# Restart a container
docker restart <container-name>

# Remove a container (must be stopped first)
docker rm <container-name>

# Force remove running container
docker rm -f <container-name>

# Remove all stopped containers
docker container prune
```

---

## Dockerfile Basics

A Dockerfile defines how to build an image. See `examples/docker/Dockerfile.example` for a complete example.

### Flask Application Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

### Jupyter Notebook Dockerfile

See `examples/docker/Dockerfile.jupyter.example`:

```dockerfile
FROM python:3.11-slim
WORKDIR /notebooks
RUN pip install --no-cache-dir jupyter jupyterlab pandas numpy matplotlib
COPY . .
EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
```

### Build Commands

```bash
# Build from Dockerfile in current directory
docker build -t my-image .

# Build with specific Dockerfile
docker build -f Dockerfile.jupyter -t my-jupyter .

# Build without cache
docker build --no-cache -t my-image .
```

---

## Docker Compose

Docker Compose allows you to define and run multi-container applications. See `examples/docker/docker-compose.example.yml`.

### Example: docker-compose.yml

```yaml
version: "3.8"

services:
  flask-app:
    build: .
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=development
    depends_on:
      - database

  database:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=myapp
    ports:
      - "5432:5432"
```

### Docker Compose Commands

```bash
# Start all services
docker compose up -d

# View running services
docker compose ps

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

---

## Volumes and Data Persistence

```bash
# Create a named volume
docker volume create mydata

# Run container with volume
docker run -d -v mydata:/app/data --name myapp my-image

# Mount host directory (for development)
docker run -d -v $(pwd):/app --name myapp my-image

# List volumes
docker volume ls

# Remove volume
docker volume rm mydata

# Remove all unused volumes
docker volume prune
```

---

## Cleanup Commands

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
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `docker build -t name .` | Build image from Dockerfile |
| `docker run -d -p 5000:5000 image` | Run container in background with port |
| `docker ps` | List running containers |
| `docker logs <container>` | View container logs |
| `docker exec -it <container> bash` | Open shell in container |
| `docker stop <container>` | Stop container |
| `docker rm <container>` | Remove container |
| `docker images` | List images |
| `docker rmi <image>` | Remove image |
| `docker compose up -d` | Start services |
| `docker compose down` | Stop services |
| `docker system prune -a` | Clean up everything |

---

## Example Files

This repository includes ready-to-use example files in `examples/docker/`:

| File | Description |
|------|-------------|
| `Dockerfile.example` | Flask application Dockerfile |
| `Dockerfile.jupyter.example` | Jupyter Lab Dockerfile |
| `app.py.example` | Sample Flask application |
| `requirements.txt.example` | Python dependencies |
| `docker-compose.example.yml` | Multi-container setup |
| `.dockerignore.example` | Files to exclude from builds |

To use them:
```bash
cd examples/docker
cp Dockerfile.example Dockerfile
cp app.py.example app.py
cp requirements.txt.example requirements.txt
docker build -t my-app .
docker run -d -p 5000:5000 --name my-app my-app
```

---

## Next Steps

1. Practice building images for your Flask applications
2. Learn about multi-stage builds for smaller images
3. Explore Docker registries (Docker Hub, GitHub Container Registry)
4. Study container orchestration with Kubernetes or Docker Swarm
5. Learn about Docker security best practices
