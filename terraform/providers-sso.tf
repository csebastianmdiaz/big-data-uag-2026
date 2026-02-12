# Provider configuration using SSO profile "inbest"
# This file demonstrates SSO-based authentication

provider "aws" {
  region  = var.aws_region
  profile = "inbest"
}
