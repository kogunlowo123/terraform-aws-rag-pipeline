# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

- Initial release of terraform-aws-rag-pipeline module
- Bedrock Knowledge Base with configurable embedding models
- OpenSearch Serverless collection with vector search support
- Encryption, network, and data access policies for OpenSearch
- S3 data source bucket with versioning and encryption
- Lambda function for triggering ingestion jobs
- Step Functions state machine for orchestrated ingestion
- EventBridge schedule for automated periodic ingestion
- Configurable chunking strategies (fixed-size, hierarchical, semantic)
- IAM roles with least-privilege policies
- Basic and complete usage examples
