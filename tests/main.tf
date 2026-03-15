module "test" {
  source = "../"

  name = "test-rag-pipeline"

  tags = {
    Project     = "rag-pipeline-test"
    Environment = "test"
  }

  # Bedrock Knowledge Base
  create_knowledge_base     = true
  knowledge_base_name       = "test-knowledge-base"
  knowledge_base_description = "Test RAG Knowledge Base"
  embedding_model_id        = "amazon.titan-embed-text-v2:0"
  embedding_dimensions      = 1024

  # OpenSearch Serverless
  create_opensearch_collection = true
  collection_name              = "test-rag-collection"
  collection_type              = "VECTORSEARCH"
  standby_replicas             = "DISABLED"
  opensearch_index_name        = "bedrock-knowledge-base-index"
  vector_field_name            = "embedding"
  text_field_name              = "text"
  metadata_field_name          = "metadata"

  # S3 Data Source
  create_data_source_bucket = true
  data_source_bucket_name   = "test-rag-data-source-bucket"
  data_source_prefix        = "documents/"
  chunking_strategy         = "FIXED_SIZE"
  chunk_max_tokens          = 300
  chunk_overlap_percentage  = 20

  # Lambda Ingestion
  create_ingestion_lambda    = true
  lambda_runtime             = "python3.12"
  lambda_timeout             = 900
  lambda_memory_size         = 512
  lambda_reserved_concurrency = 5

  # Step Functions
  create_step_function = true
  step_function_name   = "test-rag-ingestion"
}
