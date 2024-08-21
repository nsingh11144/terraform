provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "AppInstance"
  }
}

resource "aws_sqs_queue" "app_queue" {
  name = "app-queue"
}

resource "aws_dynamodb_table" "app_table" {
  name           = "app-table"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "EC2 role policy for SQS and DynamoDB access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.app_queue.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.app_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_sqs_queue_policy" "app_queue_policy" {
  queue_url = aws_sqs_queue.app_queue.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action   = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.app_queue.arn
      }
    ]
  })
}

output "instance_id" {
  value = aws_instance.app_instance.id
}

output "sqs_queue_url" {
  value = aws_sqs_queue.app_queue.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.app_table.name
}
