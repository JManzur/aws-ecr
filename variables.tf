#######################################
# Required variables:
#######################################

variable "name_prefix" {
  type        = string
  description = "[REQUIRED] Used to name and tag resources."
}

variable "app_list" {
  type = map(object({
    name           = string
    tag_mutability = string
    replication_enabled = bool
    replica_destination = map(object({
      region     = optional(string)
      account_id = optional(string)
    }))
  }))

  description = "[REQUIRED] List of applications to create ECR repositories for."
}


#######################################
# Optional variables:
#######################################

variable "encryption_configuration" {
  type        = string
  description = "[OPTIONAL] The encryption configuration for the repository. Valid values are AES256 or KMS."
  default     = "AES256"

  # Validate allow values encryption_configuration
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_configuration)
    error_message = "The encryption_configuration must be AES256 or KMS."
  }
}

variable "scanning_config" {
  type        = map(string)
  description = "[OPTIONAL] The scanning configuration for the repository."

  # Enhanced scanning: https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning-enhanced.html
  # Basic scanning: https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning-basic.html
  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.scanning_config["type"])
    error_message = "The type must be BASIC or ENHANCED."
  }

  validation {
    condition     = contains(["SCAN_ON_PUSH", "CONTINUOUS_SCAN", "MANUAL"], var.scanning_config["frequency"])
    error_message = "The frequency must be SCAN_ON_PUSH, CONTINUOUS_SCAN or MANUAL."
  }

  default = {
    "type"      = "BASIC"
    "frequency" = "SCAN_ON_PUSH"
  }
}

variable "force_delete" {
  type        = bool
  description = "[OPTIONAL] When set to true, executing 'terraform destroy' will remove all images from the repository."
  default     = false
}

variable "images_to_keep" {
  type        = number
  description = "[OPTIONAL] The number of images to retain in the repository."
  default     = 30
}