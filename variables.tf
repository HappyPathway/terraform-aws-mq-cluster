variable "broker_name" {
  description = "Name of the MQ broker"
  type        = string
}

variable "broker_config" {
  description = "Configuration block for the broker"
  type = object({
    engine_type        = optional(string)
    engine_version     = optional(string)
    host_instance_type = optional(string)
    deployment_mode    = optional(string)
    storage_type      = optional(string)
    authentication_strategy = optional(string)
    auto_minor_version_upgrade = optional(bool)
    publicly_accessible       = optional(bool)
    security_groups          = optional(list(string))
    subnet_ids              = optional(list(string))
  })
  default = {}
}

variable "user_config" {
  description = "List of broker users"
  type = list(object({
    username       = string
    password       = string
    groups        = optional(list(string))
    console_access = optional(bool)
  }))
  default = []
}

variable "maintenance_window_config" {
  description = "Maintenance window configuration"
  type = object({
    day_of_week = optional(string)
    time_of_day = optional(string)
    time_zone   = optional(string)
  })
  default = {}
}

variable "logs_config" {
  description = "Logging configuration"
  type = object({
    general = optional(bool)
    audit   = optional(bool)
  })
  default = {}
}

variable "encryption_config" {
  description = "Encryption configuration"
  type = object({
    use_aws_owned_key = optional(bool)
    kms_key_id        = optional(string)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "create_security_group" {
  description = "Whether to create a security group for the MQ broker"
  type        = bool
  default     = true
}

variable "security_group_config" {
  description = "Security group configuration"
  type = object({
    name        = optional(string)
    description = optional(string)
    vpc_id      = string
    ingress_rules = optional(list(object({
      from_port   = optional(number)
      to_port     = optional(number)
      protocol    = optional(string)
      cidr_blocks = optional(list(string))
      security_groups = optional(list(string))
    })))
  })
  default = null
}

variable "cloudwatch_logging_enabled" {
  description = "Whether to enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "create_cloudwatch_log_role" {
  description = "Whether to create an IAM role for CloudWatch logging"
  type        = bool
  default     = true
}