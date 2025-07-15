# Lambda Terraform Module

This module creates production-ready Lambda functions with IAM roles, security groups, and optional triggers.

## Features

- **Lambda Functions**: Support for ZIP and container image deployments
- **IAM Roles**: Automatic IAM role creation with customizable policies
- **VPC Support**: Optional VPC configuration with security groups
- **Encryption**: KMS encryption for environment variables
- **Monitoring**: CloudWatch logs and X-Ray tracing
- **Function URLs**: HTTP(S) endpoints for Lambda functions
- **Aliases**: Function versioning and aliases
- **Dead Letter Queues**: Error handling with SQS/SNS

## Usage

### Basic Lambda Function
```hcl
module "lambda_function" {
  source = "./lambda"

  function_name = "my-app-processor"
  description   = "Processes application events"
  
  runtime = "python3.9"
  handler = "lambda_function.lambda_handler"
  
  create_package = true
  source_path    = "${path.module}/lambda_code"

  environment_variables = {
    LOG_LEVEL = "INFO"
    REGION    = "us-east-1"
  }

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Lambda with VPC Configuration
```hcl
module "lambda_vpc" {
  source = "./lambda"

  function_name = "database-processor"
  description   = "Processes data from RDS"
  
  runtime     = "python3.9"
  handler     = "app.handler"
  timeout     = 300
  memory_size = 512

  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")

  # VPC configuration
  vpc_config = {
    vpc_id             = module.vpc.vpc_id
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = []
  }

  # IAM permissions
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  ]

  environment_variables = {
    DB_ENDPOINT = module.rds.db_instance_endpoint
    DB_NAME     = "myapp"
  }

  tags = {
    Environment = "production"
    Purpose     = "data-processing"
  }
}
```

### Lambda with Function URL
```hcl
module "lambda_api" {
  source = "./lambda"

  function_name = "api-handler"
  description   = "HTTP API handler"
  
  runtime     = "nodejs18.x"
  handler     = "index.handler"
  timeout     = 30
  memory_size = 256

  create_package = true
  source_path    = "${path.module}/api_code"

  # Function URL
  create_function_url   = true
  function_url_auth_type = "NONE"
  
  function_url_cors = {
    allow_credentials = false
    allow_headers     = ["date", "keep-alive"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["date", "keep-alive"]
    max_age          = 86400
  }

  environment_variables = {
    NODE_ENV = "production"
  }

  tags = {
    Environment = "production"
    Type        = "api"
  }
}
```

### Container Image Lambda
```hcl
module "lambda_container" {
  source = "./lambda"

  function_name = "ml-inference"
  description   = "Machine learning inference"
  
  package_type = "Image"
  image_uri    = "123456789012.dkr.ecr.us-east-1.amazonaws.com/ml-inference:latest"
  
  timeout     = 900
  memory_size = 3008

  image_config = {
    command = ["app.handler"]
  }

  ephemeral_storage_size = 2048

  environment_variables = {
    MODEL_PATH = "/opt/ml/model"
  }

  tags = {
    Environment = "production"
    Purpose     = "ml-inference"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| function_name | A unique name for your Lambda Function | `string` | n/a | yes |
| description | Description of your Lambda Function | `string` | `""` | no |
| runtime | The runtime environment for the Lambda function | `string` | `"python3.9"` | no |
| handler | The function entrypoint in your code | `string` | `"index.handler"` | no |
| timeout | The amount of time your Lambda Function has to run in seconds | `number` | `3` | no |
| memory_size | Amount of memory in MB your Lambda Function can use at runtime | `number` | `128` | no |
| package_type | The Lambda deployment package type | `string` | `"Zip"` | no |
| create_package | Whether to create a deployment package from source_path | `bool` | `false` | no |
| source_path | The path to the directory containing the Lambda function source code | `string` | `null` | no |
| vpc_config | VPC configuration for the Lambda function | `object` | `null` | no |
| environment_variables | A map that defines environment variables for the Lambda Function | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda_function_arn | The ARN of the Lambda Function |
| lambda_function_name | The name of the Lambda Function |
| lambda_function_invoke_arn | The Invoke ARN of the Lambda Function |
| lambda_function_url | The HTTP URL endpoint for the function |
| lambda_role_arn | The ARN of the IAM role created for the Lambda Function |
| lambda_cloudwatch_log_group_name | The name of the CloudWatch Log Group |

## Examples

### Event-Driven Processing
```hcl
module "s3_processor" {
  source = "./lambda"

  function_name = "s3-file-processor"
  description   = "Processes files uploaded to S3"
  
  runtime     = "python3.9"
  handler     = "processor.handler"
  timeout     = 300
  memory_size = 1024

  create_package = true
  source_path    = "${path.module}/s3_processor"

  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  environment_variables = {
    BUCKET_NAME = module.s3_bucket.bucket_id
    SNS_TOPIC   = aws_sns_topic.notifications.arn
  }

  tags = {
    Environment = "production"
    Trigger     = "s3"
  }
}

# S3 bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3_bucket.bucket_id

  lambda_function {
    lambda_function_arn = module.s3_processor.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.s3_processor.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_bucket.bucket_arn
}
```

### Scheduled Lambda
```hcl
module "scheduled_task" {
  source = "./lambda"

  function_name = "daily-report"
  description   = "Generates daily reports"
  
  runtime     = "python3.9"
  handler     = "report.handler"
  timeout     = 600
  memory_size = 512

  create_package = true
  source_path    = "${path.module}/report_generator"

  environment_variables = {
    REPORT_BUCKET = module.reports_bucket.bucket_id
  }

  tags = {
    Environment = "production"
    Schedule    = "daily"
  }
}

# EventBridge rule for scheduling
resource "aws_cloudwatch_event_rule" "daily_report" {
  name                = "daily-report-schedule"
  description         = "Trigger daily report generation"
  schedule_expression = "cron(0 6 * * ? *)"  # 6 AM UTC daily
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_report.name
  target_id = "TriggerLambda"
  arn       = module.scheduled_task.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.scheduled_task.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_report.arn
}
```
