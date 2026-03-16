################################################################################
# S3 Data Source Bucket
################################################################################

resource "aws_s3_bucket" "data_source" {
  count = var.create_data_source_bucket ? 1 : 0

  bucket        = var.data_source_bucket_name != "" ? var.data_source_bucket_name : "${var.name}-data-source"
  force_destroy = false

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "data_source" {
  count = var.create_data_source_bucket ? 1 : 0

  bucket = aws_s3_bucket.data_source[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_source" {
  count = var.create_data_source_bucket ? 1 : 0

  bucket = aws_s3_bucket.data_source[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "data_source" {
  count = var.create_data_source_bucket ? 1 : 0

  bucket                  = aws_s3_bucket.data_source[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
# OpenSearch Serverless
################################################################################

resource "aws_opensearchserverless_security_policy" "encryption" {
  count = var.create_opensearch_collection ? 1 : 0

  name = "${var.name}-enc"
  type = "encryption"

  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${var.collection_name != "" ? var.collection_name : "${var.name}-vectors"}"]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "network" {
  count = var.create_opensearch_collection ? 1 : 0

  name = "${var.name}-net"
  type = "network"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource     = ["collection/${var.collection_name != "" ? var.collection_name : "${var.name}-vectors"}"]
          ResourceType = "collection"
        },
        {
          Resource     = ["collection/${var.collection_name != "" ? var.collection_name : "${var.name}-vectors"}"]
          ResourceType = "dashboard"
        }
      ]
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_access_policy" "data" {
  count = var.create_opensearch_collection ? 1 : 0

  name = "${var.name}-data"
  type = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource     = ["collection/${var.collection_name != "" ? var.collection_name : "${var.name}-vectors"}"]
          ResourceType = "collection"
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems",
          ]
        },
        {
          Resource     = ["index/${var.collection_name != "" ? var.collection_name : "${var.name}-vectors"}/*"]
          ResourceType = "index"
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument",
          ]
        }
      ]
      Principal = concat(
        [aws_iam_role.bedrock_kb[0].arn],
        [for id in var.allowed_account_ids : "arn:${data.aws_partition.current.partition}:iam::${id}:root"]
      )
    }
  ])
}

resource "aws_opensearchserverless_collection" "this" {
  count = var.create_opensearch_collection ? 1 : 0

  name             = var.collection_name != "" ? var.collection_name : "${var.name}-vectors"
  type             = var.collection_type
  standby_replicas = var.standby_replicas

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network,
    aws_opensearchserverless_access_policy.data,
  ]

  tags = var.tags
}

################################################################################
# Bedrock Knowledge Base IAM
################################################################################

resource "aws_iam_role" "bedrock_kb" {
  count = var.create_knowledge_base ? 1 : 0

  name               = "${var.name}-bedrock-kb"
  assume_role_policy = data.aws_iam_policy_document.bedrock_assume_role[0].json

  tags = var.tags
}

resource "aws_iam_role_policy" "bedrock_kb" {
  count = var.create_knowledge_base ? 1 : 0

  name   = "${var.name}-bedrock-kb-policy"
  role   = aws_iam_role.bedrock_kb[0].id
  policy = data.aws_iam_policy_document.bedrock_kb_policy[0].json
}

################################################################################
# Bedrock Knowledge Base
################################################################################

resource "aws_bedrockagent_knowledge_base" "this" {
  count = var.create_knowledge_base ? 1 : 0

  name        = var.knowledge_base_name != "" ? var.knowledge_base_name : "${var.name}-kb"
  description = var.knowledge_base_description
  role_arn    = aws_iam_role.bedrock_kb[0].arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model_id}"
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"

    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.this[0].arn
      vector_index_name = var.opensearch_index_name

      field_mapping {
        vector_field   = var.vector_field_name
        text_field     = var.text_field_name
        metadata_field = var.metadata_field_name
      }
    }
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy.bedrock_kb,
    aws_opensearchserverless_collection.this,
  ]
}

################################################################################
# Bedrock Data Source
################################################################################

resource "aws_bedrockagent_data_source" "this" {
  count = var.create_knowledge_base ? 1 : 0

  knowledge_base_id = aws_bedrockagent_knowledge_base.this[0].id
  name              = "${var.name}-s3-source"

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn         = var.create_data_source_bucket ? aws_s3_bucket.data_source[0].arn : var.existing_bucket_arn
      inclusion_prefixes = [var.data_source_prefix]
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = var.chunking_strategy

      dynamic "fixed_size_chunking_configuration" {
        for_each = var.chunking_strategy == "FIXED_SIZE" ? [1] : []

        content {
          max_tokens         = var.chunk_max_tokens
          overlap_percentage = var.chunk_overlap_percentage
        }
      }
    }
  }
}

################################################################################
# Lambda Ingestion Function
################################################################################

resource "aws_iam_role" "lambda" {
  count = var.create_ingestion_lambda ? 1 : 0

  name               = "${var.name}-ingestion-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda" {
  count = var.create_ingestion_lambda ? 1 : 0

  name   = "${var.name}-lambda-policy"
  role   = aws_iam_role.lambda[0].id
  policy = data.aws_iam_policy_document.lambda_policy[0].json
}

data "archive_file" "ingestion" {
  count = var.create_ingestion_lambda ? 1 : 0

  type        = "zip"
  output_path = "${path.module}/.build/ingestion.zip"

  source {
    content  = <<-PYTHON
import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

bedrock_agent = boto3.client('bedrock-agent')

def handler(event, context):
    """Trigger a Bedrock Knowledge Base ingestion job."""
    knowledge_base_id = os.environ.get('KNOWLEDGE_BASE_ID', event.get('knowledge_base_id', ''))
    data_source_id = os.environ.get('DATA_SOURCE_ID', event.get('data_source_id', ''))

    if not knowledge_base_id or not data_source_id:
        raise ValueError("knowledge_base_id and data_source_id are required")

    logger.info(f"Starting ingestion for KB: {knowledge_base_id}, DS: {data_source_id}")

    response = bedrock_agent.start_ingestion_job(
        knowledgeBaseId=knowledge_base_id,
        dataSourceId=data_source_id,
    )

    ingestion_job = response['ingestionJob']

    return {
        'statusCode': 200,
        'body': json.dumps({
            'ingestionJobId': ingestion_job['ingestionJobId'],
            'knowledgeBaseId': knowledge_base_id,
            'dataSourceId': data_source_id,
            'status': ingestion_job['status'],
        })
    }
PYTHON
    filename = "index.py"
  }
}

resource "aws_lambda_function" "ingestion" {
  count = var.create_ingestion_lambda ? 1 : 0

  function_name    = "${var.name}-ingestion"
  role             = aws_iam_role.lambda[0].arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  filename         = data.archive_file.ingestion[0].output_path
  source_code_hash = data.archive_file.ingestion[0].output_base64sha256

  reserved_concurrent_executions = var.lambda_reserved_concurrency

  environment {
    variables = {
      KNOWLEDGE_BASE_ID = try(aws_bedrockagent_knowledge_base.this[0].id, "")
      DATA_SOURCE_ID    = try(aws_bedrockagent_data_source.this[0].data_source_id, "")
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  count = var.create_ingestion_lambda ? 1 : 0

  name              = "/aws/lambda/${var.name}-ingestion"
  retention_in_days = 30

  tags = var.tags
}

################################################################################
# Step Functions
################################################################################

resource "aws_iam_role" "sfn" {
  count = var.create_step_function ? 1 : 0

  name               = "${var.name}-sfn"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role[0].json

  tags = var.tags
}

resource "aws_iam_role_policy" "sfn" {
  count = var.create_step_function ? 1 : 0

  name   = "${var.name}-sfn-policy"
  role   = aws_iam_role.sfn[0].id
  policy = data.aws_iam_policy_document.sfn_policy[0].json
}

resource "aws_sfn_state_machine" "ingestion" {
  count = var.create_step_function ? 1 : 0

  name     = var.step_function_name != "" ? var.step_function_name : "${var.name}-ingestion"
  role_arn = aws_iam_role.sfn[0].arn

  definition = jsonencode({
    Comment = "RAG Ingestion Pipeline"
    StartAt = "TriggerIngestion"
    States = {
      TriggerIngestion = {
        Type     = "Task"
        Resource = "arn:${data.aws_partition.current.partition}:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.create_ingestion_lambda ? aws_lambda_function.ingestion[0].arn : ""
          Payload = {
            "knowledge_base_id.$" = "$.knowledge_base_id"
            "data_source_id.$"    = "$.data_source_id"
          }
        }
        ResultPath = "$.ingestionResult"
        Next       = "WaitForIngestion"
      }
      WaitForIngestion = {
        Type    = "Wait"
        Seconds = 30
        Next    = "CheckIngestionStatus"
      }
      CheckIngestionStatus = {
        Type     = "Task"
        Resource = "arn:${data.aws_partition.current.partition}:states:::aws-sdk:bedrockagent:getIngestionJob"
        Parameters = {
          "KnowledgeBaseId.$" = "$.knowledge_base_id"
          "DataSourceId.$"    = "$.data_source_id"
          "IngestionJobId.$"  = "$.ingestionResult.Payload.body.ingestionJobId"
        }
        ResultPath = "$.statusResult"
        Next       = "IsComplete"
      }
      IsComplete = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.statusResult.IngestionJob.Status"
            StringEquals = "COMPLETE"
            Next         = "IngestionComplete"
          },
          {
            Variable     = "$.statusResult.IngestionJob.Status"
            StringEquals = "FAILED"
            Next         = "IngestionFailed"
          }
        ]
        Default = "WaitForIngestion"
      }
      IngestionComplete = {
        Type = "Succeed"
      }
      IngestionFailed = {
        Type  = "Fail"
        Error = "IngestionFailed"
        Cause = "The ingestion job failed"
      }
    }
  })

  tags = var.tags
}

################################################################################
# EventBridge Schedule (optional)
################################################################################

resource "aws_scheduler_schedule" "ingestion" {
  count = var.create_step_function && var.ingestion_schedule != "" ? 1 : 0

  name       = "${var.name}-ingestion-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.ingestion_schedule

  target {
    arn      = aws_sfn_state_machine.ingestion[0].arn
    role_arn = aws_iam_role.sfn[0].arn

    input = jsonencode({
      knowledge_base_id = try(aws_bedrockagent_knowledge_base.this[0].id, "")
      data_source_id    = try(aws_bedrockagent_data_source.this[0].data_source_id, "")
    })
  }
}
