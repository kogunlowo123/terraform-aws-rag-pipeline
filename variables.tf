variable "name" {
  description = "Name prefix for all resources."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "create_knowledge_base" {
  description = "Whether to create the Bedrock Knowledge Base."
  type        = bool
  default     = true
}

variable "knowledge_base_name" {
  description = "Name of the knowledge base; defaults to var.name-kb if empty."
  type        = string
  default     = ""
}

variable "knowledge_base_description" {
  description = "Description of the knowledge base."
  type        = string
  default     = "RAG Knowledge Base"
}

variable "foundation_model_arn" {
  description = "ARN of the foundation model for embeddings."
  type        = string
  default     = ""
}

variable "embedding_model_id" {
  description = "ID of the embedding model (e.g., amazon.titan-embed-text-v2:0)."
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

variable "embedding_dimensions" {
  description = "Dimensions for the embedding vector."
  type        = number
  default     = 1024
}

variable "create_opensearch_collection" {
  description = "Whether to create the OpenSearch Serverless collection."
  type        = bool
  default     = true
}

variable "collection_name" {
  description = "Name of the OpenSearch Serverless collection; defaults to var.name-vectors if empty."
  type        = string
  default     = ""
}

variable "collection_type" {
  description = "Type of the OpenSearch Serverless collection."
  type        = string
  default     = "VECTORSEARCH"
}

variable "standby_replicas" {
  description = "Whether to enable standby replicas (ENABLED or DISABLED)."
  type        = string
  default     = "DISABLED"
}

variable "opensearch_index_name" {
  description = "Name of the vector index in OpenSearch."
  type        = string
  default     = "bedrock-knowledge-base-index"
}

variable "vector_field_name" {
  description = "Name of the vector field."
  type        = string
  default     = "embedding"
}

variable "text_field_name" {
  description = "Name of the text field."
  type        = string
  default     = "text"
}

variable "metadata_field_name" {
  description = "Name of the metadata field."
  type        = string
  default     = "metadata"
}

variable "create_data_source_bucket" {
  description = "Whether to create the S3 data source bucket."
  type        = bool
  default     = true
}

variable "data_source_bucket_name" {
  description = "Name of the S3 bucket for data sources; defaults to var.name-data-source if empty."
  type        = string
  default     = ""
}

variable "existing_bucket_arn" {
  description = "ARN of an existing S3 bucket to use as data source."
  type        = string
  default     = ""
}

variable "data_source_prefix" {
  description = "S3 prefix for the data source."
  type        = string
  default     = "documents/"
}

variable "chunking_strategy" {
  description = "Chunking strategy for document processing (FIXED_SIZE, NONE, HIERARCHICAL, SEMANTIC)."
  type        = string
  default     = "FIXED_SIZE"
}

variable "chunk_max_tokens" {
  description = "Maximum number of tokens per chunk."
  type        = number
  default     = 300
}

variable "chunk_overlap_percentage" {
  description = "Overlap percentage between chunks."
  type        = number
  default     = 20
}

variable "create_ingestion_lambda" {
  description = "Whether to create the ingestion Lambda function."
  type        = bool
  default     = true
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function."
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds."
  type        = number
  default     = 900
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB."
  type        = number
  default     = 512
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrent executions for the Lambda function."
  type        = number
  default     = 5
}

variable "create_step_function" {
  description = "Whether to create the Step Functions state machine."
  type        = bool
  default     = true
}

variable "step_function_name" {
  description = "Name of the Step Functions state machine; defaults to var.name-ingestion if empty."
  type        = string
  default     = ""
}

variable "ingestion_schedule" {
  description = "Schedule expression for automatic ingestion (e.g., rate(1 day))."
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID for resources that require VPC configuration."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for resources that require VPC configuration."
  type        = list(string)
  default     = []
}

variable "allowed_account_ids" {
  description = "AWS account IDs allowed to access the OpenSearch collection."
  type        = list(string)
  default     = []
}
