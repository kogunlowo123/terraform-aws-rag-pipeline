# terraform-aws-rag-pipeline

Terraform module for deploying an AWS Retrieval-Augmented Generation (RAG) pipeline using Bedrock Knowledge Bases, OpenSearch Serverless, S3, Lambda, and Step Functions.

## Architecture

```mermaid
flowchart TD
    A[S3 Data Source] --> B[Lambda Ingestion]
    B --> C[Bedrock Knowledge Base]
    C --> D[Embedding Model]
    D --> E[OpenSearch Serverless]

    F[Step Functions] --> B
    G[EventBridge Schedule] --> F

    H[User Query] --> I[Bedrock Retrieve API]
    I --> C
    C --> E
    E --> J[Relevant Chunks]
    J --> K[Foundation Model]
    K --> L[Generated Response]

    M[IAM Roles] --> B
    M --> C
    M --> F

    N[CloudWatch Logs] --> B
    N --> F

    style A fill:#FF9900,stroke:#CC7A00,color:#FFFFFF
    style B fill:#F7DC6F,stroke:#F1C40F,color:#333333
    style C fill:#5DADE2,stroke:#2E86C1,color:#FFFFFF
    style D fill:#AF7AC5,stroke:#8E44AD,color:#FFFFFF
    style E fill:#48C9B0,stroke:#1ABC9C,color:#FFFFFF
    style F fill:#F1948A,stroke:#E74C3C,color:#FFFFFF
    style G fill:#85C1E9,stroke:#3498DB,color:#FFFFFF
    style H fill:#82E0AA,stroke:#2ECC71,color:#333333
    style I fill:#5DADE2,stroke:#2E86C1,color:#FFFFFF
    style J fill:#48C9B0,stroke:#1ABC9C,color:#FFFFFF
    style K fill:#AF7AC5,stroke:#8E44AD,color:#FFFFFF
    style L fill:#82E0AA,stroke:#2ECC71,color:#333333
    style M fill:#AEB6BF,stroke:#7F8C8D,color:#FFFFFF
    style N fill:#F0B27A,stroke:#E67E22,color:#333333
```

## Features

- **Bedrock Knowledge Base** - Managed RAG with configurable embedding models
- **OpenSearch Serverless** - Vector store with encryption and access policies
- **S3 Data Source** - Versioned, encrypted bucket with configurable prefixes
- **Lambda Ingestion** - Serverless function to trigger ingestion jobs
- **Step Functions** - Orchestrated ingestion pipeline with status polling
- **EventBridge Schedule** - Automated periodic ingestion
- **IAM Roles** - Least-privilege roles for all components
- **Chunking Configuration** - Fixed-size, hierarchical, or semantic chunking

## Usage

```hcl
module "rag_pipeline" {
  source = "path/to/terraform-aws-rag-pipeline"

  name = "my-rag"

  embedding_model_id  = "amazon.titan-embed-text-v2:0"
  data_source_prefix  = "documents/"
  ingestion_schedule  = "rate(1 day)"

  tags = {
    Environment = "dev"
  }
}
```

## Examples

- [Basic](examples/basic/) - Knowledge base with S3 source and Lambda
- [Complete](examples/complete/) - Full pipeline with Step Functions and scheduling

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5.0 |
| aws       | >= 5.0   |

## License

MIT License - see [LICENSE](LICENSE) for details.
