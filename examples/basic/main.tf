provider "aws" {
  region = "us-east-1"
}

module "rag_pipeline" {
  source = "../../"

  name = "my-rag-basic"

  create_knowledge_base        = true
  create_opensearch_collection = true
  create_data_source_bucket    = true
  create_ingestion_lambda      = true
  create_step_function         = false

  embedding_model_id = "amazon.titan-embed-text-v2:0"

  tags = {
    Environment = "dev"
    Project     = "rag-basic"
  }
}

output "knowledge_base_id" {
  value = module.rag_pipeline.knowledge_base_id
}

output "collection_endpoint" {
  value = module.rag_pipeline.collection_endpoint
}
