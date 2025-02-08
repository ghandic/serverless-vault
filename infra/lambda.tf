locals {
  mount_dir = "/mnt/data"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "function_logging_policy" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}


resource "aws_iam_role" "lambda_role" {
  name               = "vaultwarden-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_lambda_function" "vaultwarden_function" {
  function_name    = "vaultwarden-serverless"
  filename         = "${path.module}/../dist/bootstrap.zip"
  source_code_hash = filebase64sha256("${path.module}/../dist/bootstrap.zip")
  role             = aws_iam_role.lambda_role.arn
  runtime          = "provided.al2"
  handler          = "index.handler" # irrelevant
  timeout          = 30
  file_system_config {
    arn              = aws_efs_access_point.ap.arn
    local_mount_path = local.mount_dir
  }
  depends_on = [
    aws_cloudwatch_log_group.function_log_group,
    aws_efs_mount_target.fs
  ]
  vpc_config {
    subnet_ids         = [aws_subnet.public.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  environment {
    variables = {
      IP_HEADER    = "X-Forwarded-For"
      DOMAIN       = "https://${var.gateway_domain}"
      DATA_FOLDER  = local.mount_dir
      ADMIN_TOKEN  = data.external.vaultwarden_admin_hash.result.hash
      DATABASE_URL = local.neon_database_url

      SMTP_HOST           = "smtp.resend.com"
      SMTP_PORT           = 587
      SMTP_SECURITY       = "starttls"
      SMTP_USERNAME       = "resend"
      SMTP_PASSWORD       = var.resend_api_key
      SMTP_AUTH_MECHANISM = "Login"
      SMTP_FROM           = var.smtp_from
    }
  }
}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/vaultwarden"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
