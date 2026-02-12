# CloudFormation Quick Start

## Deploy from AWS Console (Easiest Method)

1. **Open AWS Console** → CloudFormation
2. **Create stack** → Upload template file
3. **Select** `data-lake-stack.yaml`
4. **Enter parameters:**
   - Stack name: `big-data-lab-stack`
   - BucketName: `datalake-taxi-villarreal-2017` (change if taken)
   - ProjectName: `big-data-lab`
   - Environment: `dev`
   - GlueDatabaseName: `taxi_database`
5. **Check** "I acknowledge that AWS CloudFormation might create IAM resources"
6. **Create stack** and wait ~5-10 minutes

## After Deployment

1. **Run Glue Crawler:**
   ```bash
   aws glue start-crawler --name big-data-lab-taxi-crawler
   ```

2. **Query in Athena:**
   - Workgroup: `big-data-lab-analytics`
   - Database: `taxi_database`
   - Query: `SELECT * FROM taxi_database.taxis LIMIT 10;`

## Cleanup

```bash
aws cloudformation delete-stack --stack-name big-data-lab-stack
```

That's it! 🚀
