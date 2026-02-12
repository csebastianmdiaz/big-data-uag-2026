# Quick Docker Commands for Data Wrangling Notebook

## Start Docker Cluster

```bash
cd /Users/jerome/Documents/big-data-uag-2026
./infrastructure/scripts/start-cluster.sh spark
```

## Access Jupyter Lab

1. Open browser: **http://localhost:8888**
2. Navigate to: `labs/02_etl_pipeline/06_data_wrangling_completo.ipynb`

## Stop Cluster

```bash
./infrastructure/scripts/stop-cluster.sh
```

## Alternative: Manual Docker Commands

### Start cluster manually:
```bash
cd infrastructure
docker compose -f docker-compose.spark.yml up -d --build
```

### Check status:
```bash
docker ps
```

### View logs:
```bash
docker compose -f docker-compose.spark.yml logs -f jupyter
```

### Access container shell:
```bash
docker exec -it jupyter-spark bash
```

### Stop cluster:
```bash
docker compose -f docker-compose.spark.yml down
```

## Fix: Remove Unused Import

The notebook has an unused `import re` on line ~585. To fix it manually:

1. Open the notebook in Jupyter Lab
2. Find the cell with "3.3 Limpiar supp2"
3. Remove the line: `import re`

Or it can be left as-is - it won't cause any errors, just a minor code quality issue.

## Verify Setup

After starting, verify:
- Jupyter Lab: http://localhost:8888 ✅
- Spark Master: http://localhost:8080 ✅
- Spark Worker: http://localhost:8081 ✅

## Troubleshooting

**Port in use:**
```bash
./infrastructure/scripts/stop-cluster.sh
# Wait a few seconds, then start again
```

**Container not starting:**
```bash
docker compose -f infrastructure/docker-compose.spark.yml logs jupyter
```

**Rebuild containers:**
```bash
docker compose -f infrastructure/docker-compose.spark.yml up -d --build
```
