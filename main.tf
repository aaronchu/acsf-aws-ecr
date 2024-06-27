data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create the ECR repo(s) with appropriate permissions
resource "aws_ecr_repository" "repo" {
  name = var.repo_name

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    application = var.repo_name,
    environment = var.environment_name,
    managedby   = "Terraform"
  }
}

data "aws_iam_policy_document" "ecr_repo_private_policy" {
  statement {
    sid    = "Allow upload"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.github_ecr_push_role.arn]
    }
  }

  dynamic "statement" {
    for_each = length(var.lambda_iam_role_names) > 0 ? ["1"] : []
    content {
      sid    = "Allow Lambda Functions"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:GetDownloadUrlForLayer",
      ]
      principals {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }
      principals {
        type        = "AWS"
        identifiers = [for name in var.lambda_iam_role_names : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${name}"]
      }
    }
  }
}

resource "aws_ecr_repository_policy" "app_repo_policy" {
  repository = aws_ecr_repository.repo.name
  policy     = data.aws_iam_policy_document.ecr_repo_private_policy.json
}

resource "aws_ecr_lifecycle_policy" "repo_lifecycle_policy" {
  repository = aws_ecr_repository.repo.name
  policy     = var.repo_lifecycle_policy
}

# Create an IAM Role that can upload images to the repo(s) above
resource "aws_iam_role" "github_ecr_push_role" {
  name               = var.uploader_role_name
  assume_role_policy = data.aws_iam_policy_document.ecr_assume_role_policy.json
}

locals {
  root_iam_user_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}

data "aws_iam_policy_document" "ecr_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type        = "AWS"
      identifiers = concat(var.uploader_user_arns, [data.aws_caller_identity.current.account_id])
    }
  }
}

resource "aws_iam_policy" "github_ecr_push_policy" {
  name        = "GitHubECRPushPolicy"
  description = "Policy for GitHub pushing Docker images to ECR"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecr_push_attachment" {
  policy_arn = aws_iam_policy.github_ecr_push_policy.arn
  role       = aws_iam_role.github_ecr_push_role.name
}
