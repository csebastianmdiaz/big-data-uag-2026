# Docker Setup Guide for Data Wrangling Notebook

This guide explains how to upload and access the `06_data_wrangling_completo.ipynb` notebook in Docker.

## Prerequisites

- Docker Desktop installed and running
- At least 8GB RAM available for Docker
- Terminal/Command line access

## Step 1: Start the Docker Cluster

From the project root directory:

```bash
cd /Users/jerome/Documents/big-data-uag-2026
./infrastructure/scripts/start-cluster.sh spark
```

This will:
- Build the Jupyter and Spark containers
- Start Spark Master and Worker
- Start Jupyter Lab
- Mount the necessary volumes

**Expected output:**
```
[OK] Docker esta disponible
[INFO] Iniciando cluster Spark...
[INFO] Esperando a que los servicios esten listos...

[OK] Cluster Spark iniciado!

  Spark Master UI:  http://localhost:8080
  Spark Worker UI:  http://localhost:8081
  Jupyter Lab:      http://localhost:8888
  Spark App UI:     http://localhost:4040 (cuando hay una app corriendo)
```

## Step 2: Access Jupyter Lab

1. Open your web browser
2. Navigate to: **http://localhost:8888**
3. You should see the Jupyter Lab interface

**Note:** The notebook is already available because the `labs` directory is mounted as a volume.

## Step 3: Navigate to the Notebook

In Jupyter Lab:
1. Click on **`labs`** folder in the file browser (left sidebar)
2. Click on **`02_etl_pipeline`** folder
3. Click on **`06_data_wrangling_completo.ipynb`**

The notebook is now ready to use!

## Alternative: Copy Notebook to Container (if needed)

If for some reason the notebook is not visible, you can copy it manually:

```bash
# Copy notebook to container
docker cp labs/02_etl_pipeline/06_data_wrangling_completo.ipynb \
  jupyter-spark:/home/jovyan/labs/02_etl_pipeline/
```

## Step 4: Verify the Setup

Run the first cell of the notebook to verify everything works:

```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import *
import json
import os
import shutil
from datetime import datetime

spark = SparkSession.builder \
    .appName("DataWrangling_M06") \
    .config("spark.sql.legacy.timeParserPolicy", "LEGACY") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")

BASE_DIR = "/home/jovyan/data/m06_wrangling"
os.makedirs(BASE_DIR, exist_ok=True)

print(f"Spark {spark.version} listo")
print(f"Directorio de trabajo: {BASE_DIR}")
```

**Expected output:**
```
Spark 3.5.0 listo
Directorio de trabajo: /home/jovyan/data/m06_wrangling
```

## Directory Structure in Container

The Docker setup mounts the following directories:

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `./data` | `/home/jovyan/data` | Data files and working directories |
| `./labs` | `/home/jovyan/labs` | All notebooks (including this one) |
| `./src` | `/home/jovyan/src` | Source code modules |

## Troubleshooting

### Port 8888 Already in Use

```bash
# Stop existing containers
./infrastructure/scripts/stop-cluster.sh

# Or manually:
docker compose -f infrastructure/docker-compose.spark.yml down
```

### Container Not Starting

```bash
# Check logs
docker compose -f infrastructure/docker-compose.spark.yml logs jupyter

# Rebuild containers
docker compose -f infrastructure/docker-compose.spark.yml up -d --build
```

### Notebook Not Visible

1. Check that the `labs` directory is mounted:
   ```bash
   docker exec jupyter-spark ls -la /home/jovyan/labs/02_etl_pipeline/
   ```

2. If missing, restart the cluster:
   ```bash
   ./infrastructure/scripts/stop-cluster.sh
   ./infrastructure/scripts/start-cluster.sh spark
   ```

### Spark Connection Issues

1. Verify Spark Master is running:
   - Open http://localhost:8080
   - You should see the Spark Master UI

2. Check Spark connection in notebook:
   ```python
   spark.conf.get("spark.master")
   # Should show: spark://spark-master:7077
   ```

### Permission Issues

If you get permission errors:

```bash
# Fix permissions (run from project root)
chmod -R 755 labs/
chmod -R 755 data/
```

## Stopping the Cluster

When you're done:

```bash
./infrastructure/scripts/stop-cluster.sh
```

Or manually:
```bash
docker compose -f infrastructure/docker-compose.spark.yml down
```

## Quick Reference Commands

```bash
# Start cluster
./infrastructure/scripts/start-cluster.sh spark

# Stop cluster
./infrastructure/scripts/stop-cluster.sh

# View logs
docker compose -f infrastructure/docker-compose.spark.yml logs -f jupyter

# Access container shell
docker exec -it jupyter-spark bash

# Check running containers
docker ps

# Rebuild containers
docker compose -f infrastructure/docker-compose.spark.yml up -d --build
```

## Access URLs

Once the cluster is running:

- **Jupyter Lab**: http://localhost:8888
- **Spark Master UI**: http://localhost:8080
- **Spark Worker UI**: http://localhost:8081
- **Spark Application UI**: http://localhost:4040 (when a Spark app is running)

## Next Steps

1. Open the notebook in Jupyter Lab
2. Run cells sequentially
3. Check Spark UI at http://localhost:4040 when running Spark jobs
4. Data will be saved to `/home/jovyan/data/m06_wrangling/` inside the container
   (which maps to `./data/m06_wrangling/` on your host)
