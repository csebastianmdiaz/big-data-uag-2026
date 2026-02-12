# Provider configuration using standard access keys
# This file demonstrates access key-based authentication
# 
# IMPORTANT: When using this provider, you must also include variables-keys.tf
# which defines the aws_access_key_id and aws_secret_access_key variables.
# 
# You can either:
# 1. Copy variables-keys.tf content into variables.tf, OR
# 2. Keep both files (Terraform will read all .tf files)

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}
