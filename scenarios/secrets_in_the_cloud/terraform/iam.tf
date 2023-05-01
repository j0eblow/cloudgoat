resource "aws_iam_user" "low_priv_user" {
  name = "low-priv-user-${var.cgid}"
}

resource "aws_iam_access_key" "low_priv_user_key" {
  user = aws_iam_user.low_priv_user.name
}

resource "aws_iam_policy" "low_priv_user_s3_policy" {
  name        = "low_priv_user_s3_policy-${var.cgid}"
  description = "Policy to allow low_priv_user to list and read objects in the S3 bucket created by the scenario and list their user policies and policy attachments"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [aws_s3_bucket.cg-secrets-bucket.arn]
      },
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = ["${aws_s3_bucket.cg-secrets-bucket.arn}/*"]
      },
      {
        Action = [
          "iam:ListUserPolicies",
          "iam:GetUserPolicy",
          "iam:ListAttachedUserPolicies"
        ]
        Effect   = "Allow"
        Resource = [aws_iam_user.low_priv_user.arn]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "low_priv_user_s3_attachment" {
  user       = aws_iam_user.low_priv_user.name
  policy_arn = aws_iam_policy.low_priv_user_s3_policy.arn
}

resource "aws_iam_policy" "low_priv_user_lambda_policy" {
  name        = "low_priv_user_lambda_policy-${var.cgid}"
  description = "Policy to allow low_priv_user to enumerate and invoke the Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:ListFunctions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = aws_lambda_function.this.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "low_priv_user_lambda_attachment" {
  user       = aws_iam_user.low_priv_user.name
  policy_arn = aws_iam_policy.low_priv_user_lambda_policy.arn
}

resource "aws_iam_user" "secrets_manager_user" {
  name = "${var.cgid}-secrets-manager-user"
}

resource "aws_iam_access_key" "secrets_manager_user_key" {
  user = aws_iam_user.secrets_manager_user.name
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "lambda-role-policy-${var.cgid}"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:Describe*",
          "rds:List*"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = "secretsmanager:GetSecretValue"
        Effect = "Allow"
        Resource = aws_secretsmanager_secret.this.arn
      }
    ]
  })
}

resource "aws_iam_role" "secrets_manager_role" {
  name = "secrets-manager-role-${var.cgid}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.lambda_execution.arn
        }
      }
    ]
  })
}

resource "aws_iam_user_policy" "secrets_manager_user_policy" {
  name = "secrets-manager-policy-${var.cgid}"
  user = aws_iam_user.secrets_manager_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "DynamoDBAccess"
  description = "Allow EC2 instance access to the DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "dynamodb:*"
        Resource = aws_dynamodb_table.secrets_table.arn
      },
      {
        Effect   = "Allow"
        Action   = "dynamodb:ListTables"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_dynamodb_role" {
  name = "EC2DynamoDBRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_dynamodb_role_attachment" {
  policy_arn = aws_iam_policy.dynamodb_access.arn
  role       = aws_iam_role.ec2_dynamodb_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_dynamodb_role.name
}
