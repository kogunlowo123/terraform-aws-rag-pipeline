locals {
  knowledge_base_name  = var.knowledge_base_name != "" ? var.knowledge_base_name : "${var.name}-kb"
  collection_name      = var.collection_name != "" ? var.collection_name : "${var.name}-vectors"
  bucket_name          = var.data_source_bucket_name != "" ? var.data_source_bucket_name : "${var.name}-data-source"
  step_function_name   = var.step_function_name != "" ? var.step_function_name : "${var.name}-ingestion"
  account_id           = data.aws_caller_identity.current.account_id
  region               = data.aws_region.current.name
  partition            = data.aws_partition.current.partition

  data_source_bucket_arn = var.create_data_source_bucket ? aws_s3_bucket.data_source[0].arn : var.existing_bucket_arn

  common_tags = merge(var.tags, {
    Module    = "terraform-aws-rag-pipeline"
    ManagedBy = "terraform"
  })
}
