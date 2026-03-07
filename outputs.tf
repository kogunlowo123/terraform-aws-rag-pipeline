################################################################################
# Knowledge Base
################################################################################

output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base"
  value       = try(aws_bedrockagent_knowledge_base.this[0].id, null)
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = try(aws_bedrockagent_knowledge_base.this[0].arn, null)
}

output "data_source_id" {
  description = "ID of the Bedrock data source"
  value       = try(aws_bedrockagent_data_source.this[0].data_source_id, null)
}

################################################################################
# OpenSearch Serverless
################################################################################

output "collection_id" {
  description = "ID of the OpenSearch Serverless collection"
  value       = try(aws_opensearchserverless_collection.this[0].id, null)
}

output "collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = try(aws_opensearchserverless_collection.this[0].arn, null)
}

output "collection_endpoint" {
  description = "Endpoint of the OpenSearch Serverless collection"
  value       = try(aws_opensearchserverless_collection.this[0].collection_endpoint, null)
}

output "dashboard_endpoint" {
  description = "Dashboard endpoint of the OpenSearch Serverless collection"
  value       = try(aws_opensearchserverless_collection.this[0].dashboard_endpoint, null)
}

################################################################################
# S3
################################################################################

output "data_source_bucket_id" {
  description = "ID of the data source S3 bucket"
  value       = try(aws_s3_bucket.data_source[0].id, null)
}

output "data_source_bucket_arn" {
  description = "ARN of the data source S3 bucket"
  value       = local.data_source_bucket_arn
}

################################################################################
# Lambda
################################################################################

output "ingestion_lambda_arn" {
  description = "ARN of the ingestion Lambda function"
  value       = try(aws_lambda_function.ingestion[0].arn, null)
}

output "ingestion_lambda_function_name" {
  description = "Name of the ingestion Lambda function"
  value       = try(aws_lambda_function.ingestion[0].function_name, null)
}

################################################################################
# Step Functions
################################################################################

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = try(aws_sfn_state_machine.ingestion[0].arn, null)
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = try(aws_sfn_state_machine.ingestion[0].name, null)
}

################################################################################
# IAM
################################################################################

output "bedrock_kb_role_arn" {
  description = "ARN of the Bedrock Knowledge Base IAM role"
  value       = try(aws_iam_role.bedrock_kb[0].arn, null)
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = try(aws_iam_role.lambda[0].arn, null)
}

output "sfn_role_arn" {
  description = "ARN of the Step Functions IAM role"
  value       = try(aws_iam_role.sfn[0].arn, null)
}
