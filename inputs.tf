variable "environment_name" {
  description = "The environment where this repo belongs"
  type        = string
  default     = "production" # normally we should only keep production repos (as they are cross-environment)
}

variable "repo_name" {
  description = "The name of the AWS ECR to create"
  type        = string
}

variable "uploader_role_name" {
  description = "Name of the role that can upload to this repo"
  type        = string
}

variable "uploader_user_arns" {
  description = "List of ARNs of IAM users that can assume the uploader role"
  type        = list(string)
  default     = [] # Default is empty in case unused
}

variable "lambda_iam_role_names" {
  description = "List of names of IAM roles accessing via lambda"
  type        = list(string)
  default     = [] # Default to an empty string if no name is passed in
}

variable "repo_lifecycle_policy" {
  description = "Lifecycle policy for the repo"
  type        = string
  default     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 365 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 365
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}