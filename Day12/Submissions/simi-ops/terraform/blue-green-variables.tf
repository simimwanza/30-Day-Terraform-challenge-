variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type per environment"
  type        = map(string)
  default = {
    dev        = "t3.micro"
    staging    = "t3.small"
    production = "t3.medium"
  }
}

variable "min_size" {
  description = "Minimum number of instances per environment"
  type        = map(number)
  default = {
    dev        = 1
    staging    = 2
    production = 2
  }
}

variable "max_size" {
  description = "Maximum number of instances per environment"
  type        = map(number)
  default = {
    dev        = 2
    staging    = 4
    production = 6
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "deployment_state" {
  description = "Current deployment state (blue or green)"
  type        = string
  default     = "blue"
  validation {
    condition     = contains(["blue", "green"], var.deployment_state)
    error_message = "Deployment state must be either 'blue' or 'green'."
  }
}

variable "traffic_distribution" {
  description = "Percentage of traffic to route to the new environment during deployment (0-100)"
  type        = number
  default     = 0
  validation {
    condition     = var.traffic_distribution >= 0 && var.traffic_distribution <= 100
    error_message = "Traffic distribution must be between 0 and 100."
  }
}

variable "blue_app_version" {
  description = "Application version for the blue environment"
  type        = string
  default     = "1.0.0"
}

variable "green_app_version" {
  description = "Application version for the green environment"
  type        = string
  default     = "1.0.0"
}