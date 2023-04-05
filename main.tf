resource "aws_kms_key" "ecr_encryption" {
  count = var.encryption_configuration == "KMS" ? 1 : 0

  description             = "${var.name_prefix}-ecr-encryption-key"
  deletion_window_in_days = 15
}

resource "aws_kms_alias" "ecr_encryption" {
  count = var.encryption_configuration == "KMS" ? 1 : 0

  name          = "alias/${var.name_prefix}-ecr-encryption-key"
  target_key_id = aws_kms_key.ecr_encryption[0].key_id
}

resource "aws_ecr_repository" "this" {
  for_each = { for app in var.app_list : app.git_repo => app }

  name                 = each.value.name
  image_tag_mutability = each.value.tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scanning_config["frequency"] == "SCAN_ON_PUSH" ? true : false
  }

  encryption_configuration {
    encryption_type = var.encryption_configuration
    kms_key         = var.encryption_configuration == "KMS" ? aws_kms_key.ecr_encryption[0].arn : null
  }

  force_delete = var.force_delete

  tags = { Name = "${each.value.name}" }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = toset(values(aws_ecr_repository.this)[*].name)
  repository = each.key

  policy = jsonencode({
    "rules" : [
      {
        "action" : {
          "type" : "expire"
        },
        "selection" : {
          "countType" : "imageCountMoreThan",
          "countNumber" : var.images_to_keep,
          "tagStatus" : "any"
        },
        "description" : "Keep last ${var.images_to_keep} images",
        "rulePriority" : 1
      }
    ]
  })
}

resource "aws_ecr_registry_scanning_configuration" "this" {
  scan_type = var.scanning_config["type"]

  rule {
    scan_frequency = var.scanning_config["frequency"]
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_replication_configuration" "this" {
  for_each = { for app_name, app_config in var.app_list : app_name => app_config if app_config.replication_enabled }

  rule {
    destination {
      region     = each.value.replica_destination.region
      account_id = each.value.replica_destination.account_id == "self" ? data.aws_caller_identity.current.account_id : each.value.replica_destination.account_id
    }

    repository_filter {
      filter      = each.value.name
      filter_type = "PREFIX_MATCH"
    }
  }
}