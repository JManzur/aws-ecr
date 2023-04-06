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
  for_each = { for app in var.app_list : app.name => app }

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
      filter      = var.scanning_config["filter"]
      filter_type = "WILDCARD"
    }
  }
}

locals {
  app_list_with_replication_enabled = [ for app in var.app_list : app if app.replication_enabled == true ]
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_replication_configuration" "this" {
  for_each = { for app in local.app_list_with_replication_enabled : app.name => app }

  replication_configuration {
    dynamic "rule" {
      for_each = each.value.replica_destination

      content {
        destination {
          region     = rule.value.region
          registry_id = rule.value.account_id == "self" ? data.aws_caller_identity.current.account_id : rule.value.account_id
        }

        repository_filter {
          filter      = each.value.name
          filter_type = "PREFIX_MATCH"
        }
      }
    }
  }
}

/*
In order to replicate images to another AWS account, you need to create a replication policy in the destination account.
This policy grants permission to the destination account to create a repository and replicate images to it.
It's important to note that the replication policy should be created in the destination account, not the source account.

Here's an example of a replication policy that grants permission to the destination account to create a repository and replicate images to it:

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_ecr_registry_policy" "cross_account_replication" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "CrossAccountReplication"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.source_account_id}:root"
        }
        Action = [
          "ecr:CreateRepository",
          "ecr:BatchImportUpstreamImage",
          "ecr:ReplicateImage"
        ]
        "Resource": "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
      }
    ]
  })
}

*/