variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Groups"
  type        = list(string)
}

variable "load_balancer_arn" {
  description = "ARN of the load balancer"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group for instances"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}