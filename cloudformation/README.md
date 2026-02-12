# CloudFormation Template for S3, Glue, and Athena

This CloudFormation template deploys a complete data lake infrastructure on AWS with:
- **S3 Bucket**: For storing taxi trip data
- **Sample Data**: Automatically generated and uploaded via Lambda function
- **AWS Glue**: Database and crawler for cataloging data
- **AWS Athena**: Workgroup for querying data

## Key Differences from Terraform

| Feature | Terraform | CloudFormation |
|---------|-----------|----------------|
| **Language** | HCL (HashiCorp Configuration Language) | YAML/JSON |
| **Provider Config** | Separate provider blocks | Uses AWS credentials from console/CLI |
| **File Uploads** | Direct file references | Lambda function generates and uploads data |
| **State Management** | Local/remote state files | Managed by AWS CloudFormation service |
| **Deployment** | `terraform apply` | AWS Console or `aws cloudformation create-stack` |
| **Modularity** | Modules, workspaces | Nested stacks, imports |

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS Console access** or AWS CLI configured
3. **Permissions** to create:
   - S3 buckets
   - Lambda functions
   - IAM roles
   - Glue databases and crawlers
   - Athena workgroups

## Quick Start: Deploy from AWS Console

### Step 1: Open CloudFormation Console

1. Log in to the AWS Console
2. Navigate to **CloudFormation** service
3. Click **Create stack** → **With new resources (standard)**

### Step 2: Upload Template

1. Select **Upload a template file**
2. Click **Choose file** and select `data-lake-stack.yaml`
3. Click **Next**

### Step 3: Specify Stack Details

Enter the following parameters:

- **Stack name**: `big-data-lab-stack` (or your preferred name)
- **BucketName**: `datalake-taxi-villarreal-2017` (must be globally unique - change if needed)
- **ProjectName**: `big-data-lab` (or your preferred name)
- **Environment**: `dev` (or `staging`, `prod`)
- **GlueDatabaseName**: `taxi_database` (or your preferred name)

Click **Next**

### Step 4: Configure Stack Options (Optional)

- Add tags if desired
- Configure stack failure options
- Set up notifications (optional)

Click **Next**

### Step 5: Review and Create

1. Review all settings
2. Check the **I acknowledge that AWS CloudFormation might create IAM resources** checkbox
3. Click **Create stack**

### Step 6: Wait for Stack Creation

The stack creation will take approximately 5-10 minutes. You can monitor progress in the **Events** tab.

**What happens during creation:**
1. S3 buckets are created
2. IAM roles are created
3. Lambda function is created
4. Sample data is generated and uploaded to S3
5. Glue database is created
6. Glue crawler is created
7. Athena workgroup is created

## Deploy via AWS CLI

### Using SSO Profile "inbest"

```bash
aws cloudformation create-stack \
  --profile inbest \
  --stack-name big-data-lab-stack \
  --template-body file://data-lake-stack.yaml \
  --parameters \
    ParameterKey=BucketName,ParameterValue=datalake-taxi-villarreal-2017 \
    ParameterKey=ProjectName,ParameterValue=big-data-lab \
    ParameterKey=Environment,ParameterValue=dev \
    ParameterKey=GlueDatabaseName,ParameterValue=taxi_database \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

### Using Access Keys

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1

aws cloudformation create-stack \
  --stack-name big-data-lab-stack \
  --template-body file://data-lake-stack.yaml \
  --parameters \
    ParameterKey=BucketName,ParameterValue=datalake-taxi-villarreal-2017 \
    ParameterKey=ProjectName,ParameterValue=big-data-lab \
    ParameterKey=Environment,ParameterValue=dev \
    ParameterKey=GlueDatabaseName,ParameterValue=taxi_database \
  --capabilities CAPABILITY_NAMED_IAM
```

### Monitor Stack Creation

```bash
aws cloudformation describe-stacks --stack-name big-data-lab-stack --query 'Stacks[0].StackStatus'
```

### View Stack Outputs

```bash
aws cloudformation describe-stacks \
  --stack-name big-data-lab-stack \
  --query 'Stacks[0].Outputs'
```

## After Deployment

### 1. Run the Glue Crawler

The crawler needs to be started manually to catalog the data:

**Via AWS Console:**
1. Go to **AWS Glue** → **Crawlers**
2. Select the crawler: `big-data-lab-taxi-crawler`
3. Click **Run crawler**
4. Wait for it to complete (status will show "Ready")

**Via AWS CLI:**
```bash
aws glue start-crawler --name big-data-lab-taxi-crawler

# Check status
aws glue get-crawler --name big-data-lab-taxi-crawler --query 'Crawler.State'
```

### 2. Query Data with Athena

Once the crawler completes:

1. Go to **AWS Athena** Console
2. In the query editor, select:
   - **Workgroup**: `big-data-lab-analytics`
   - **Database**: `taxi_database`
3. Run sample queries:

```sql
-- List tables
SHOW TABLES IN taxi_database;

-- Query sample data
SELECT * FROM taxi_database.taxis LIMIT 10;

-- Count records
SELECT COUNT(*) FROM taxi_database.taxis;

-- Query by payment type
SELECT paytype, COUNT(*) as count, AVG(total) as avg_total
FROM taxi_database.taxis
GROUP BY paytype;

-- Query by month
SELECT 
  EXTRACT(MONTH FROM CAST(pickup AS TIMESTAMP)) as month,
  COUNT(*) as trips,
  AVG(total) as avg_fare
FROM taxi_database.taxis
GROUP BY EXTRACT(MONTH FROM CAST(pickup AS TIMESTAMP))
ORDER BY month;
```

## Stack Outputs

After successful deployment, the stack provides these outputs:

- **DataLakeBucketName**: Name of the S3 data lake bucket
- **DataLakeBucketArn**: ARN of the S3 data lake bucket
- **GlueDatabaseName**: Name of the Glue database
- **GlueCrawlerName**: Name of the Glue crawler
- **AthenaWorkgroupName**: Name of the Athena workgroup
- **AthenaResultsBucket**: S3 bucket for Athena query results
- **SampleQueries**: Example Athena queries

View outputs in the console or via CLI:
```bash
aws cloudformation describe-stacks \
  --stack-name big-data-lab-stack \
  --query 'Stacks[0].Outputs'
```

## Cleanup

To delete all resources:

**Via AWS Console:**
1. Go to CloudFormation
2. Select your stack
3. Click **Delete**
4. Confirm deletion

**Via AWS CLI:**
```bash
aws cloudformation delete-stack --stack-name big-data-lab-stack
```

**Warning**: This will delete:
- S3 buckets and all their contents (including uploaded data)
- Lambda function
- Glue database and crawler
- Athena workgroup
- IAM roles

## Troubleshooting

### Stack Creation Fails

1. **Check CloudFormation Events**: Look at the Events tab to see which resource failed
2. **Check Lambda Logs**: If Lambda fails, check CloudWatch Logs for the function
3. **Common Issues**:
   - Bucket name already exists (change `BucketName` parameter)
   - Insufficient IAM permissions
   - Region-specific issues (ensure you're in the correct region)

### Lambda Function Errors

If data upload fails:
1. Check CloudWatch Logs: `/aws/lambda/big-data-lab-upload-sample-data`
2. Verify IAM role has S3 permissions
3. Check that the bucket was created successfully

### Glue Crawler Not Finding Data

1. Ensure the Lambda function completed successfully
2. Verify files exist in S3: `s3://<bucket-name>/landing/taxis/`
3. Check crawler IAM role has S3 read permissions
4. Verify crawler target path is correct

### Athena Queries Failing

1. Ensure Glue crawler has completed successfully
2. Verify tables exist in the Glue database
3. Check that the correct workgroup is selected
4. Verify Athena results bucket exists and is accessible

## Template Structure

```
data-lake-stack.yaml
├── Parameters
│   ├── BucketName
│   ├── ProjectName
│   ├── Environment
│   └── GlueDatabaseName
├── Resources
│   ├── DataLakeBucket (S3)
│   ├── AthenaResultsBucket (S3)
│   ├── LambdaExecutionRole (IAM)
│   ├── UploadSampleDataFunction (Lambda)
│   ├── LambdaInvokePermission (Lambda Permission)
│   ├── InvokeUploadFunction (Custom Resource)
│   ├── GlueServiceRole (IAM)
│   ├── GlueDatabase (Glue)
│   ├── GlueCrawler (Glue)
│   └── AthenaWorkgroup (Athena)
└── Outputs
    └── (All resource names and ARNs)
```

## Comparison: Terraform vs CloudFormation

### When to Use Terraform
- Multi-cloud deployments
- Complex state management needs
- Team prefers HCL syntax
- Need advanced features (workspaces, modules)
- Want local state management

### When to Use CloudFormation
- AWS-only deployments
- Prefer AWS-native tooling
- Want AWS Console integration
- Need AWS Service Catalog integration
- Team familiar with YAML/JSON

## Next Steps

- Add more data partitions
- Configure Glue ETL jobs
- Set up additional Athena workgroups
- Add CloudWatch monitoring and alarms
- Configure S3 lifecycle policies
- Add data validation and quality checks

## Security Notes

1. S3 buckets are configured with public access blocked
2. IAM roles follow least privilege principle
3. Lambda function only has permissions to upload to the specific bucket
4. Athena results are encrypted with SSE-S3
5. Consider adding bucket policies for additional access control
