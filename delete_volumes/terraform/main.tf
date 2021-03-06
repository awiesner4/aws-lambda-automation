terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  version = "= 2.61.0"
}

resource "aws_iam_role" "saas_delete_available_volumes" {
  name = "devops_delete_available_volumes"
  description = "Managed by Terraform: Allow deletion of available volumes"
  assume_role_policy = file("./aws-lambda-automation/delete_volumes/terraform/files/assume_role_policy.json")
}

resource "aws_iam_role_policy" "delete_available_volumes" {
  name = "sshRotationPolicy"
  policy = templatefile("./aws-lambda-automation/delete_volumes/terraform/templates/lambda_execution_policy.json",
    {
      region = var.region,
      accountNumber = var.accountNumber
    }
  )

  role = aws_iam_role.saas_delete_available_volumes.id

  depends_on = [aws_iam_role.saas_delete_available_volumes]
}

resource "aws_lambda_function" "delete_available_volumes" {
  function_name = "saas_delete_available_volumes"
  handler = "delete_volumes.lambda_handler"
  role = aws_iam_role.saas_delete_available_volumes.arn
  runtime = "python3.7"
  filename = "./aws-lambda-automation/delete_volumes/terraform/scripts/delete_volumes.zip"
  timeout = "600"
}

resource "aws_cloudwatch_event_rule" "delete_available_volumes" {
  name = "delete_available_volumes"
  description = "Managed by Terraform: deletion of available EBS volumes"
  schedule_expression = "rate(${var.rate} ${var.metric})"
}

resource "aws_cloudwatch_event_target" "delete_available_volumes_lambda" {
  arn = aws_lambda_function.delete_available_volumes.arn
  rule = aws_cloudwatch_event_rule.delete_available_volumes.name
}
