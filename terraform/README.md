# Terraform Configuration for S3, Glue, and Athena

This Terraform configuration deploys a basic data lake infrastructure on AWS with:
- **S3 Bucket**: For storing taxi trip data
- **AWS Glue**: Database and crawler for cataloging data
- **AWS Athena**: Workgroup for querying data

## Prerequisites

1. **Terraform installed** (version >= 1.0)
   ```bash
   terraform version
   ```

2. **AWS CLI configured** with appropriate credentials

3. **Sample data files** in `../s3-glue-lab/`:
   - `taxi_full.csv`
   - `taxi_enero.csv`
   - `taxi_tarjeta.csv`

## Authentication Methods

This configuration supports two authentication methods:

### Method 1: SSO Profile (Recommended for AWS SSO users)

Uses the AWS SSO profile "inbest" for authentication.

**Setup Steps:**

1. Copy the SSO provider configuration:
   ```bash
   cp providers-sso.tf providers.tf
   ```

2. Copy and customize the SSO example variables:
   ```bash
   cp terraform.tfvars.example.sso terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your values:
   ```hcl
   aws_region         = "us-east-1"
   bucket_name        = "datalake-taxi-villarreal-2017"
   project_name       = "big-data-lab"
   environment        = "dev"
   glue_database_name = "taxi_database"
   ```

4. Ensure your AWS SSO profile "inbest" is configured:
   ```bash
   aws configure sso --profile inbest
   ```

### Method 2: Standard Access Keys

Uses AWS Access Key ID and Secret Access Key for authentication.

**Setup Steps:**

1. Copy the access keys provider configuration:
   ```bash
   cp providers-keys.tf providers.tf
   ```

2. Copy the access keys variables file:
   ```bash
   cp variables-keys.tf variables.tf
   # Or append to existing variables.tf
   ```

3. Copy and customize the access keys example variables:
   ```bash
   cp terraform.tfvars.example.keys terraform.tfvars
   ```

4. Edit `terraform.tfvars` with your values:
   ```hcl
   aws_region            = "us-east-1"
   bucket_name           = "datalake-taxi-villarreal-2017"
   project_name          = "big-data-lab"
   environment           = "dev"
   glue_database_name    = "taxi_database"
   aws_access_key_id     = "YOUR_ACCESS_KEY_ID"
   aws_secret_access_key = "YOUR_SECRET_ACCESS_KEY"
   ```

   **OR** set via environment variables (more secure):
   ```bash
   export TF_VAR_aws_access_key_id="YOUR_ACCESS_KEY_ID"
   export TF_VAR_aws_secret_access_key="YOUR_SECRET_ACCESS_KEY"
   ```

## Usage

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

This will show you what resources will be created:
- S3 bucket for data lake
- S3 bucket for Athena results
- IAM role for Glue
- Glue database
- Glue crawler
- Athena workgroup
- Sample data files uploaded to S3

### 3. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 4. Run the Glue Crawler

After Terraform creates the resources, you need to run the Glue crawler to catalog the data:

```bash
# Using AWS CLI
aws glue start-crawler --name big-data-lab-taxi-crawler

# Or via Terraform (add this to main.tf if you want it automated)
# resource "aws_glue_crawler" "taxi_crawler" {
#   ...
# }
# 
# resource "null_resource" "run_crawler" {
#   depends_on = [aws_glue_crawler.taxi_crawler]
#   triggers = {
#     crawler_id = aws_glue_crawler.taxi_crawler.id
#   }
#   provisioner "local-exec" {
#     command = "aws glue start-crawler --name ${aws_glue_crawler.taxi_crawler.name}"
#   }
# }
```

Wait for the crawler to finish (check status):
```bash
aws glue get-crawler --name big-data-lab-taxi-crawler
```

### 5. Query Data with Athena

Once the crawler completes, you can query the data:

1. Go to AWS Athena Console
2. Select the workgroup: `big-data-lab-analytics`
3. Select the database: `taxi_database`
4. Run queries:

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
```

## Outputs

After applying, Terraform will output:

- `s3_bucket_name`: Name of the data lake bucket
- `s3_bucket_arn`: ARN of the data lake bucket
- `glue_database_name`: Name of the Glue database
- `glue_crawler_name`: Name of the Glue crawler
- `athena_workgroup_name`: Name of the Athena workgroup
- `athena_results_bucket`: S3 bucket for Athena query results
- `sample_queries`: Example Athena queries

View outputs:
```bash
terraform output
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete the S3 bucket and all its contents, including the uploaded data files.

## File Structure

```
terraform/
├── main.tf                          # Main Terraform configuration
├── variables.tf                     # Variable definitions
├── outputs.tf                       # Output definitions
├── providers-sso.tf                # SSO profile provider example
├── providers-keys.tf               # Access keys provider example
├── variables-keys.tf                # Additional variables for access keys
├── providers.tf.example            # Provider configuration examples
├── terraform.tfvars.example.sso    # Example variables for SSO
├── terraform.tfvars.example.keys   # Example variables for access keys
└── README.md                        # This file
```

## Security Notes

1. **Never commit `terraform.tfvars`** with real credentials to version control
2. Add `terraform.tfvars` to `.gitignore`
3. Use environment variables for sensitive values when possible
4. Consider using AWS Secrets Manager or Parameter Store for production
5. The S3 buckets are configured with public access blocked by default

## Troubleshooting

### Error: "No valid credential sources found"
- Check that your AWS profile is configured correctly
- For SSO: Run `aws sso login --profile inbest`
- For access keys: Verify credentials in `terraform.tfvars` or environment variables

### Error: "Bucket name already exists"
- S3 bucket names must be globally unique
- Change the `bucket_name` in `terraform.tfvars`

### Glue Crawler not finding data
- Ensure the crawler has run to completion
- Check that files are in the expected S3 paths
- Verify IAM permissions for the Glue role

### Athena queries failing
- Ensure the Glue crawler has completed successfully
- Check that tables exist in the Glue database
- Verify the Athena workgroup is selected in the console

## Next Steps

- Add more data partitions
- Configure Glue ETL jobs
- Set up additional Athena workgroups
- Add CloudWatch monitoring
- Configure lifecycle policies for S3
