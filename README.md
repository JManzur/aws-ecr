# AWS ECR Terraform module.

This Terraform module provides an easy-to-use solution to deploy AWS Elastic Container Registry (ECR) repositories, with customizable settings such as encryption, lifecycle policy, replication (cross-region and cross-account).

## How to use this modue:

```bash
module "aws-ecr" {
  source = "git::https://github.com/JManzur/aws-ecr.git?ref=v1.0.0"

  # Required variables:
  name_prefix = "si"
  app_list = [
    {
      name                = "app1"
      tag_mutability      = "MUTABLE"
      replication_enabled = true
      replica_destination = [
        {
          region     = "us-east-2"
          account_id = "self"
        }
      ]
    },
    {
      name                = "app2"
      tag_mutability      = "IMMUTABLE"
      replication_enabled = false
    }
  ]

  # Optional variables:
  encryption_configuration = "KMS"
  scanning_config = {
    "type"      = "ENHANCED"
    "frequency" = "CONTINUOUS_SCAN"
    "filter"    = "app*"
  }
  force_delete = true
  images_to_keep = 10
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_registry_scanning_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_scanning_configuration) | resource |
| [aws_ecr_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_replication_configuration) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_kms_alias.ecr_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.ecr_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | [OPTIONAL] List of capacity providers to use for the cluster. | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | [OPTIONAL] Enable container insights for the cluster. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | [REQUIRED] Used to name and tag resources. | `string` | n/a | yes |
| <a name="input_execute_command_log_retention"></a> [execute\_command\_log\_retention](#input\_execute\_command\_log\_retention) | [OPTIONAL] The number of days to retain log events in the log group for the execute command configuration. | `number` | `7` | no |
| <a name="input_include_execute_command_configuration"></a> [include\_execute\_command\_configuration](#input\_include\_execute\_command\_configuration) | [OPTIONAL] Enable execute command configuration for the cluster. | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | [REQUIRED] Used to name and tag resources. | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | [OPTIONAL] Used to name and tag global resources. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_identifiers"></a> [ecr\_repository\_identifiers](#output\_ecr\_repository\_identifiers) | Attributes that identify the ECR Repository |
