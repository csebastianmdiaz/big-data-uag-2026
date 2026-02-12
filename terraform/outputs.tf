output "s3_bucket_name" {
  description = "Name of the S3 data lake bucket"
  value       = aws_s3_bucket.datalake.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 data lake bucket"
  value       = aws_s3_bucket.datalake.arn
}

output "glue_database_name" {
  description = "Name of the Glue database"
  value       = aws_glue_catalog_database.taxi_database.name
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.taxi_crawler.name
}

output "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = aws_athena_workgroup.analytics.name
}

output "athena_results_bucket" {
  description = "S3 bucket for Athena query results"
  value       = aws_s3_bucket.athena_results.id
}

output "sample_queries" {
  description = "Sample Athena queries to run"
  value = {
    list_tables = "SHOW TABLES IN ${aws_glue_catalog_database.taxi_database.name};"
    query_data  = "SELECT * FROM ${aws_glue_catalog_database.taxi_database.name}.taxis LIMIT 10;"
  }
}
