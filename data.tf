data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

################################################################################
# IAM - Bedrock Knowledge Base
################################################################################

data "aws_iam_policy_document" "bedrock_assume_role" {
  count = var.create_knowledge_base ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

data "aws_iam_policy_document" "bedrock_kb_policy" {
  count = var.create_knowledge_base ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
    ]
    resources = ["arn:${local.partition}:bedrock:${local.region}::foundation-model/${var.embedding_model_id}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "aoss:APIAccessAll",
    ]
    resources = var.create_opensearch_collection ? [aws_opensearchserverless_collection.this[0].arn] : []
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      local.data_source_bucket_arn,
      "${local.data_source_bucket_arn}/*",
    ]
  }
}

################################################################################
# IAM - Lambda
################################################################################

data "aws_iam_policy_document" "lambda_assume_role" {
  count = var.create_ingestion_lambda ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  count = var.create_ingestion_lambda ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:${local.partition}:logs:${local.region}:${local.account_id}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "bedrock:StartIngestionJob",
      "bedrock:GetIngestionJob",
      "bedrock:ListIngestionJobs",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = [
      local.data_source_bucket_arn,
      "${local.data_source_bucket_arn}/*",
    ]
  }
}

################################################################################
# IAM - Step Functions
################################################################################

data "aws_iam_policy_document" "sfn_assume_role" {
  count = var.create_step_function ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sfn_policy" {
  count = var.create_step_function ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = var.create_ingestion_lambda ? [aws_lambda_function.ingestion[0].arn] : []
  }

  statement {
    effect = "Allow"
    actions = [
      "bedrock:StartIngestionJob",
      "bedrock:GetIngestionJob",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
    ]
    resources = ["*"]
  }
}
