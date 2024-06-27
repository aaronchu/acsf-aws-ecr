# `acsf-aws-ecr` Terraform Module

## Purpose

Establish an AWS ECR to support apps such as lambda.

## Inputs

| Variable | Type | Example | Description |
| - | - | - | - |
| `environment_name` | `string` | `production` | (required) The environment where this repo belongs. |
| `repo_name` | `string` | `my-repo` | (required) The name of the AWS ECR to create. |
| `uploader_role_name` | `string` | `my-repo-uploader` | (required) Name of the role that can upload to this repo. Module will create this. |
| `uploader_user_arns` | `list(string)` | `["arn:aws:iam::123456789012:user/uploader-user"]` | (optional) List of ARNs of IAM users that can assume the uploader role. Default to none. |
| `lambda_iam_role_names` | `list(string)` | `["lambda-exec-role","lambda-exec-role-2"]` | (optional) List of names of IAM roles accessing via lambda. Default to none. |
| `repo_lifecycle_policy` | `string` | [examples here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html) | (optional) Lifecycle policy for the repo. Defaults to 1yr retention. |

## Outputs

| Variable | Type | Example | Description |
| - | - | - | - |
| `ecr_uploader_role_arn` | `string` | `production` | (required) The environment where this repo belongs. |
| `ecr_repo_url` | `string` | `my-repo` | (required) The name of the AWS ECR to create. |

## Usage

Using the module:

```
module "static_website" {
  source           = "git::https://github.com/aaronchu/acsf-aws-ecr.git?ref=v0.1.0"
  repo_name             = "my-repo"
  uploader_role_name    = "my-repo-uploader"
  uploader_user_arns    = [aws_iam_user.uploader-user.arn]
  lambda_iam_role_names = ["lambda-exec-role"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.7 |
| aws | ~> 5.0 |

## Providers

`aws` (see requirements)

## Notes

1. Intended for hobbyist use only.
2. Built with `terraform` version `1.5.x` and intent to move to [`opentofu`](https://opentofu.org/) eventually.
