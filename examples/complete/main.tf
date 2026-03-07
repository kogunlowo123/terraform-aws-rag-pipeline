provider "aws" {
  region = "us-east-1"
}

module "rag_pipeline" {
  source = "../../"

  name = "my-rag-production"

  create_knowledge_base        = true
  create_opensearch_collection = true
  create_data_source_bucket    = true
  create_ingestion_lambda      = true
  create_step_function         = true

  # Knowledge Base
  knowledge_base_description = "Production RAG knowledge base"
  embedding_model_id         = "amazon.titan-embed-text-v2:0"
  embedding_dimensions       = 1024

  # OpenSearch
  collection_type  = "VECTORSEARCH"
  standby_replicas = "ENABLED"

  # S3 Data Source
  data_source_prefix       = "knowledge-docs/"
  chunking_strategy        = "FIXED_SIZE"
  chunk_max_tokens         = 500
  chunk_overlap_percentage = 15

  # Lambda
  lambda_runtime              = "python3.12"
  lambda_timeout              = 900
  lambda_memory_size          = 1024
  lambda_reserved_concurrency = 10

  # Step Functions with schedule
  ingestion_schedule = "rate(6 hours)"

  # Access control
  allowed_account_ids = ["123456789012"]

  tags = {
    Environment = "production"
    Project     = "rag-platform"
    CostCenter  = "ml-ops"
  }
}

output "knowledge_base_id" {
  value = module.rag_pipeline.knowledge_base_id
}

output "collection_endpoint" {
  value = module.rag_pipeline.collection_endpoint
}

output "state_machine_arn" {
  value = module.rag_pipeline.state_machine_arn
}

output "ingestion_lambda_arn" {
  value = module.rag_pipeline.ingestion_lambda_arn
}
