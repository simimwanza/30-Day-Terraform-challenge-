terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

locals {
  name_prefix = "${var.environment}-web"

  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "30-day-terraform-challenge"
    Day         = "12"
  })
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "blue_green" {
  source = "./modules/blue-green"

  environment       = var.environment
  name_prefix       = local.name_prefix
  ami_id            = data.aws_ami.amazon_linux.id
  instance_type     = var.instance_type[var.environment]
  
  min_size          = var.min_size[var.environment]
  max_size          = var.max_size[var.environment]
  desired_capacity  = var.min_size[var.environment]
  
  deployment_state  = var.deployment_state
  traffic_distribution = var.traffic_distribution
  
  blue_app_version  = var.blue_app_version
  green_app_version = var.green_app_version
  
  tags              = local.common_tags
}

# SSM Parameter to store current deployment state
resource "aws_ssm_parameter" "deployment_state" {
  name        = "/${var.environment}/web-app/deployment-state"
  description = "Current deployment state (blue or green)"
  type        = "String"
  value       = var.deployment_state
  
  tags = local.common_tags
}

# SSM Parameter to store traffic distribution
resource "aws_ssm_parameter" "traffic_distribution" {
  name        = "/${var.environment}/web-app/traffic-distribution"
  description = "Current traffic distribution percentage"
  type        = "String"
  value       = tostring(var.traffic_distribution)
  
  tags = local.common_tags
}

# SSM Parameter to store blue app version
resource "aws_ssm_parameter" "blue_app_version" {
  name        = "/${var.environment}/web-app/blue-version"
  description = "Current blue environment application version"
  type        = "String"
  value       = var.blue_app_version
  
  tags = local.common_tags
}

# SSM Parameter to store green app version
resource "aws_ssm_parameter" "green_app_version" {
  name        = "/${var.environment}/web-app/green-version"
  description = "Current green environment application version"
  type        = "String"
  value       = var.green_app_version
  
  tags = local.common_tags
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.blue_green.alb_dns_name
}

output "active_environment" {
  description = "Currently active environment (blue or green)"
  value       = module.blue_green.active_environment
}

output "blue_weight" {
  description = "Current traffic weight for blue environment"
  value       = module.blue_green.blue_weight
}

output "green_weight" {
  description = "Current traffic weight for green environment"
  value       = module.blue_green.green_weight
}

output "deployment_instructions" {
  description = "Instructions for performing a zero-downtime deployment"
  value       = <<-EOT
    To perform a zero-downtime deployment:
    
    1. Update the inactive environment's application version:
       - If currently on blue: Update green_app_version
       - If currently on green: Update blue_app_version
    
    2. Apply the changes to deploy the new version to the inactive environment:
       terraform apply -var-file="environments/${var.environment}/terraform.tfvars"
    
    3. Gradually shift traffic to the new environment:
       terraform apply -var-file="environments/${var.environment}/terraform.tfvars" -var="traffic_distribution=10"
       
       Monitor the application and increase traffic gradually:
       terraform apply -var-file="environments/${var.environment}/terraform.tfvars" -var="traffic_distribution=25"
       terraform apply -var-file="environments/${var.environment}/terraform.tfvars" -var="traffic_distribution=50"
       terraform apply -var-file="environments/${var.environment}/terraform.tfvars" -var="traffic_distribution=75"
       terraform apply -var-file="environments/${var.environment}/terraform.tfvars" -var="traffic_distribution=100"
    
    4. Complete the deployment by switching the active environment:
       terraform apply -var-file="environments/${var.environment}/terraform.tfvars" -var="deployment_state=${module.blue_green.active_environment == "blue" ? "green" : "blue"}" -var="traffic_distribution=0"
    
    5. To rollback, simply switch back to the previous environment:
       terraform apply -var-file="environments/${var.environment}/terraform.tfvars" -var="deployment_state=${module.blue_green.active_environment}" -var="traffic_distribution=0"
  EOT
}