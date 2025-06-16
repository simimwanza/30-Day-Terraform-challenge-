# Zero-downtime deployment implementation using blue/green strategy

# Get default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for blue/green instances
resource "aws_security_group" "blue_green" {
  name        = "blue-green-sg"
  description = "Security group for blue/green deployment"
  vpc_id      = data.aws_vpc.default.id

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Health check port
  ingress {
    description = "Health Check"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "blue-green-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "blue_green" {
  name               = "blue-green-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.blue_green.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "blue-green-alb"
  }
}

# Latest Amazon Linux 2 AMI
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

# Blue/Green deployment module
module "blue_green" {
  source = "./blue-green"

  name_prefix        = "webapp"
  vpc_id             = data.aws_vpc.default.id
  subnet_ids         = data.aws_subnets.default.ids
  load_balancer_arn  = aws_lb.blue_green.arn
  security_group_id  = aws_security_group.blue_green.id
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  
  min_size           = 1
  max_size           = 3
  desired_capacity   = 1
  
  deployment_state   = "blue"  # Initial deployment state
  traffic_distribution = 0     # Initial traffic distribution
  
  blue_app_version   = "1.0.0"
  green_app_version  = "1.0.0"
  
  tags = {
    Project = "30-day-terraform-challenge"
    Day     = "12"
  }
}

# SSM Parameter to store current deployment state
resource "aws_ssm_parameter" "deployment_state" {
  name        = "/webapp/deployment-state"
  description = "Current deployment state (blue or green)"
  type        = "String"
  value       = "blue"  # Initial state
  
  tags = {
    Project = "30-day-terraform-challenge"
  }
}

# SSM Parameter to store traffic distribution
resource "aws_ssm_parameter" "traffic_distribution" {
  name        = "/webapp/traffic-distribution"
  description = "Current traffic distribution percentage"
  type        = "String"
  value       = "0"  # Initial distribution
  
  tags = {
    Project = "30-day-terraform-challenge"
  }
}

# Output the ALB DNS name
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.blue_green.dns_name
}

# Output the active environment
output "active_environment" {
  description = "Currently active environment (blue or green)"
  value       = module.blue_green.active_environment
}

# Output deployment instructions
output "deployment_instructions" {
  description = "Instructions for performing a zero-downtime deployment"
  value       = <<-EOT
    To perform a zero-downtime deployment:
    
    1. Update the inactive environment's application version:
       terraform apply -var='green_app_version=2.0.0'
    
    2. Gradually shift traffic to the new environment:
       terraform apply -var='traffic_distribution=10'
       terraform apply -var='traffic_distribution=50'
       terraform apply -var='traffic_distribution=100'
    
    3. Complete the deployment by switching the active environment:
       terraform apply -var='deployment_state=green' -var='traffic_distribution=0'
    
    4. To rollback, switch back to the previous environment:
       terraform apply -var='deployment_state=blue' -var='traffic_distribution=0'
  EOT
}