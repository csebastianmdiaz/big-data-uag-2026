# Big Data UAG 2026

Repository for Big Data course materials and projects.

## Contents

- Docker guides and examples
- Big data tools and configurations
- Course projects

## Documentation

- [Docker Beginner's Guide](docs/docker-guide.md) - Complete guide to Docker, containers, images, and Docker Compose

## Examples

The `examples/` directory contains ready-to-use templates:

- `examples/docker/Dockerfile.example` - Node.js Dockerfile template
- `examples/docker/Dockerfile.python.example` - Python Dockerfile template
- `examples/docker/docker-compose.example.yml` - Multi-service Docker Compose template
- `examples/docker/.dockerignore.example` - Dockerignore template

## Getting Started

Clone this repository:

```bash
git clone https://github.com/agusvillarreal/big-data-uag-2026.git
cd big-data-uag-2026
```

## Quick Start with Docker

1. Install Docker on your system (see [Docker Guide](docs/docker-guide.md#installation))
2. Copy example files to your project:
   ```bash
   cp examples/docker/Dockerfile.example ./Dockerfile
   cp examples/docker/docker-compose.example.yml ./docker-compose.yml
   cp examples/docker/.dockerignore.example ./.dockerignore
   ```
3. Modify the files according to your project needs
4. Build and run:
   ```bash
   docker compose up -d
   ```
