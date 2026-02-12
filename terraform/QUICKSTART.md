# Quick Start Guide

## Option 1: Using SSO Profile "inbest" (Recommended)

```bash
cd terraform

# 1. Copy SSO provider configuration
cp providers-sso.tf providers.tf

# 2. Copy and edit variables
cp terraform.tfvars.example.sso terraform.tfvars
# Edit terraform.tfvars with your bucket name

# 3. Initialize and apply
terraform init
terraform plan
terraform apply
```

## Option 2: Using Access Keys

```bash
cd terraform

# 1. Copy access keys provider configuration
cp providers-keys.tf providers.tf

# 2. Copy variables file for access keys
# (variables.tf already exists, just add variables-keys.tf)
# Terraform will automatically read both files

# 3. Copy and edit variables
cp terraform.tfvars.example.keys terraform.tfvars
# Edit terraform.tfvars with your credentials and bucket name

# 4. Initialize and apply
terraform init
terraform plan
terraform apply
```

## After Deployment

1. **Run the Glue Crawler:**
   ```bash
   aws glue start-crawler --name big-data-lab-taxi-crawler
   ```

2. **Wait for crawler to complete:**
   ```bash
   aws glue get-crawler --name big-data-lab-taxi-crawler
   ```

3. **Query in Athena:**
   - Go to AWS Athena Console
   - Select workgroup: `big-data-lab-analytics`
   - Select database: `taxi_database`
   - Run: `SELECT * FROM taxi_database.taxis LIMIT 10;`

## Cleanup

```bash
terraform destroy
```
