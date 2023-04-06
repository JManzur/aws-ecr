#######################################
# Required variables:
#######################################

variable "name_prefix" {
  type        = string
  description = "[REQUIRED] Used to name and tag resources."
}

variable "environment" {
  type        = string
  description = "[REQUIRED] Used to name and tag resources."
}

#######################################
# Optional variables:
#######################################

variable "name_suffix" {
  type        = string
  description = "[OPTIONAL] Used to name and tag global resources."
  default     = ""
}

variable "capacity_providers" {
  type        = list(string)
  description = "[OPTIONAL] List of capacity providers to use for the cluster."
  default     = ["FARGATE"]

  validation {
    condition     = length(var.capacity_providers) > 0
    error_message = "At least one capacity provider must be specified."
  }
  validation {
    condition     = length([for provider in var.capacity_providers : provider if provider == "FARGATE_SPOT" || provider == "FARGATE"]) == length(var.capacity_providers)
    error_message = "Only FARGATE_SPOT and FARGATE are valid capacity providers."
  }
}

variable "enable_container_insights" {
  type        = bool
  description = "[OPTIONAL] Enable container insights for the cluster." # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch-container-insights.html
  default     = true
  # Default to true: https://aquasecurity.github.io/tfsec/v1.28.1/checks/aws/ecs/enable-container-insight/
}

variable "include_execute_command_configuration" {
  type        = bool
  description = "[OPTIONAL] Enable execute command configuration for the cluster." # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html
  default     = false
}

variable "execute_command_log_retention" {
  type        = number
  description = "[OPTIONAL] The number of days to retain log events in the log group for the execute command configuration."
  default     = 7

  validation {
    condition = (
      var.execute_command_log_retention == 1 ||
      var.execute_command_log_retention == 3 ||
      var.execute_command_log_retention == 5 ||
      var.execute_command_log_retention == 7 ||
      var.execute_command_log_retention == 14 ||
      var.execute_command_log_retention == 30 ||
      var.execute_command_log_retention == 60 ||
      var.execute_command_log_retention == 90 ||
      var.execute_command_log_retention == 120 ||
      var.execute_command_log_retention == 150 ||
      var.execute_command_log_retention == 180 ||
      var.execute_command_log_retention == 365 ||
      var.execute_command_log_retention == 400 ||
      var.execute_command_log_retention == 545 ||
      var.execute_command_log_retention == 731 ||
      var.execute_command_log_retention == 1096 ||
      var.execute_command_log_retention == 1827 ||
      var.execute_command_log_retention == 2192 ||
      var.execute_command_log_retention == 2557 ||
      var.execute_command_log_retention == 2922 ||
      var.execute_command_log_retention == 3288 ||
      var.execute_command_log_retention == 3653
    )
    error_message = "The number of days to retain log events must be one of the following: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}