output "ecr_repository_identifiers" {
  description = "Attributes that identify the ECR Repository"
  value = {
    arn            = try(aws_ecr_repository.this.arn, null)
    registry_id    = try(aws_ecr_repository.this.registry_id, null)
    repository_url = try(aws_ecr_repository.this.repository_url, null)
  }
}