output "ecr_repository_identifiers" {
  description = "Attributes that identify the ECR Repository"
  value = {
    arn            = try(values(aws_ecr_repository.this)[*].arn, null)
    registry_id    = try(values(aws_ecr_repository.this)[*].registry_id, null)
    repository_url = try(values(aws_ecr_repository.this)[*].repository_url, null)
  }
  # Usage: module.<module_name>.ecr_repository_identifiers.<attribute_name>[<index>]
}