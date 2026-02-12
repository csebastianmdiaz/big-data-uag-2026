terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# S3 Bucket for Data Lake
resource "aws_s3_bucket" "datalake" {
  bucket = var.bucket_name

  tags = {
    Name        = "Data Lake Bucket"
    Environment = var.environment
    Project     = "Big Data Lab"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "datalake" {
  bucket = aws_s3_bucket.datalake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "datalake" {
  bucket = aws_s3_bucket.datalake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload sample data files
resource "aws_s3_object" "taxi_full" {
  bucket = aws_s3_bucket.datalake.id
  key    = "landing/taxis/2017/taxi_full.csv"
  source = "${path.module}/../s3-glue-lab/taxi_full.csv"
  etag   = filemd5("${path.module}/../s3-glue-lab/taxi_full.csv")
}

resource "aws_s3_object" "taxi_enero" {
  bucket = aws_s3_bucket.datalake.id
  key    = "landing/taxis/2017/enero/taxi_enero.csv"
  source = "${path.module}/../s3-glue-lab/taxi_enero.csv"
  etag   = filemd5("${path.module}/../s3-glue-lab/taxi_enero.csv")
}

resource "aws_s3_object" "taxi_tarjeta" {
  bucket = aws_s3_bucket.datalake.id
  key    = "landing/taxis/2017/paytype_1/taxi_tarjeta.csv"
  source = "${path.module}/../s3-glue-lab/taxi_tarjeta.csv"
  etag   = filemd5("${path.module}/../s3-glue-lab/taxi_tarjeta.csv")
}

# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "Glue Service Role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach AWS managed policy for Glue
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Additional policy for S3 access
resource "aws_iam_role_policy" "glue_s3_access" {
  name = "${var.project_name}-glue-s3-access"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.datalake.arn,
          "${aws_s3_bucket.datalake.arn}/*"
        ]
      }
    ]
  })
}

# Glue Database
resource "aws_glue_catalog_database" "taxi_database" {
  name        = var.glue_database_name
  description = "Database for taxi trip data"
}

# Glue Crawler
resource "aws_glue_crawler" "taxi_crawler" {
  database_name = aws_glue_catalog_database.taxi_database.name
  name          = "${var.project_name}-taxi-crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.id}/landing/taxis/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  tags = {
    Name        = "Taxi Data Crawler"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Athena Workgroup
resource "aws_athena_workgroup" "analytics" {
  name = "${var.project_name}-analytics"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.datalake.id}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = {
    Name        = "Analytics Workgroup"
    Environment = var.environment
    Project     = var.project_name
  }
}

# S3 bucket for Athena query results
resource "aws_s3_bucket" "athena_results" {
  bucket = "${var.bucket_name}-athena-results"

  tags = {
    Name        = "Athena Query Results"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
