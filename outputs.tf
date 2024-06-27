output "ecr_uploader_role_arn" {
  value = aws_iam_role.github_ecr_push_role.arn
}
output "ecr_repo_url" {
  value = aws_ecr_repository.repo.repository_url
}