variable "stage" {
  default   = "dev"
  type      = string
}

locals {
  function_name = "Policy-Reader"
}

data "aws_iam_policy_document" "policy_reader_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "policy_reader" {
  name               = "Lambda-${local.function_name}-${var.stage}"
  assume_role_policy = data.aws_iam_policy_document.policy_reader_assume_role.json
}

data "archive_file" "policy_reader_archive" {
  type        = "zip"
  source_file = "src/policy_reader/policy_reader.py"
  output_path = "policy_reader_payload.zip"
}

resource "aws_lambda_function" "policy_reader" {

  filename      = "policy_reader_payload.zip"
  function_name = "${local.function_name}-${var.stage}"
  role          = aws_iam_role.policy_reader.arn
  handler       = "policy_reader.lambda_handler"
  timeout       = 30

  source_code_hash = data.archive_file.policy_reader_archive.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      stage = var.stage
    }
  }
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = "placeholder"
  description      = "a sample description"
  function_name    = aws_lambda_function.policy_reader.arn
  function_version = "1"

  routing_config {
    additional_version_weights = {
      "2" = 0.5
    }
  }
}
