terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  module_version = "1.0.0"
  blue_name      = "${var.name_prefix}-blue"
  green_name     = "${var.name_prefix}-green"
  
  # Determine which environment is active based on the deployment_state variable
  active_environment  = var.deployment_state == "blue" ? "blue" : "green"
  inactive_environment = var.deployment_state == "blue" ? "green" : "blue"
  
  # Set traffic distribution based on deployment_state and traffic_distribution
  blue_weight  = var.deployment_state == "blue" ? 100 - var.traffic_distribution : var.traffic_distribution
  green_weight = var.deployment_state == "green" ? 100 - var.traffic_distribution : var.traffic_distribution
  
  # User data templates for blue and green environments
  blue_user_data = templatefile("${path.module}/user_data.sh.tpl", {
    environment = "blue"
    app_version = var.blue_app_version
    color       = "#0000FF"  # Blue color for visual identification
  })
  
  green_user_data = templatefile("${path.module}/user_data.sh.tpl", {
    environment = "green"
    app_version = var.green_app_version
    color       = "#00FF00"  # Green color for visual identification
  })
}

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

# Security group for both blue and green environments
resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for blue/green web deployment"

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access - restricted based on environment
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.environment == "production" ? ["10.0.0.0/8"] : ["0.0.0.0/0"]
  }

  # Health check port
  ingress {
    description = "Health Check"
    from_port   = 8080
    to_port     = 8080
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

  tags = merge(var.tags, {
    Name          = "${var.name_prefix}-sg"
    Module        = "blue-green"
    ModuleVersion = local.module_version
  })
}

# Launch template for blue environment
resource "aws_launch_template" "blue" {
  name_prefix   = "${local.blue_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(local.blue_user_data)
  
  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
    }
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name          = "${local.blue_name}-instance"
      Environment   = "blue"
      AppVersion    = var.blue_app_version
      Module        = "blue-green"
      ModuleVersion = local.module_version
    })
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Launch template for green environment
resource "aws_launch_template" "green" {
  name_prefix   = "${local.green_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(local.green_user_data)
  
  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
    }
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name          = "${local.green_name}-instance"
      Environment   = "green"
      AppVersion    = var.green_app_version
      Module        = "blue-green"
      ModuleVersion = local.module_version
    })
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# IAM role and instance profile for EC2 instances
resource "aws_iam_role" "web" {
  name = "${var.name_prefix}-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.web.name
}

# Auto Scaling Group for blue environment
resource "aws_autoscaling_group" "blue" {
  name                = "${local.blue_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = data.aws_subnets.default.ids
  
  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }
  
  health_check_type         = "ELB"
  health_check_grace_period = 300
  
  target_group_arns = [aws_lb_target_group.blue.arn]
  
  lifecycle {
    create_before_destroy = true
  }
  
  tag {
    key                 = "Name"
    value               = "${local.blue_name}-instance"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Environment"
    value               = "blue"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "AppVersion"
    value               = var.blue_app_version
    propagate_at_launch = true
  }
}

# Auto Scaling Group for green environment
resource "aws_autoscaling_group" "green" {
  name                = "${local.green_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = data.aws_subnets.default.ids
  
  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }
  
  health_check_type         = "ELB"
  health_check_grace_period = 300
  
  target_group_arns = [aws_lb_target_group.green.arn]
  
  lifecycle {
    create_before_destroy = true
  }
  
  tag {
    key                 = "Name"
    value               = "${local.green_name}-instance"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Environment"
    value               = "green"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "AppVersion"
    value               = var.green_app_version
    propagate_at_launch = true
  }
}

# Application Load Balancer
resource "aws_lb" "web" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = data.aws_subnets.default.ids
  
  enable_deletion_protection = var.environment == "production"
  
  tags = merge(var.tags, {
    Name          = "${var.name_prefix}-alb"
    Module        = "blue-green"
    ModuleVersion = local.module_version
  })
}

# Target group for blue environment
resource "aws_lb_target_group" "blue" {
  name     = "${local.blue_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  
  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
  
  tags = merge(var.tags, {
    Name          = "${local.blue_name}-tg"
    Environment   = "blue"
    Module        = "blue-green"
    ModuleVersion = local.module_version
  })
}

# Target group for green environment
resource "aws_lb_target_group" "green" {
  name     = "${local.green_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  
  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
  
  tags = merge(var.tags, {
    Name          = "${local.green_name}-tg"
    Environment   = "green"
    Module        = "blue-green"
    ModuleVersion = local.module_version
  })
}

# Listener for HTTP traffic
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = local.blue_weight
      }
      
      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = local.green_weight
      }
      
      stickiness {
        enabled  = true
        duration = 600
      }
    }
  }
}

# CloudWatch alarm for high CPU in blue environment
resource "aws_cloudwatch_metric_alarm" "blue_high_cpu" {
  alarm_name          = "${local.blue_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors blue environment cpu utilization"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.blue.name
  }
  
  tags = merge(var.tags, {
    Name        = "${local.blue_name}-high-cpu"
    Environment = "blue"
  })
}

# CloudWatch alarm for high CPU in green environment
resource "aws_cloudwatch_metric_alarm" "green_high_cpu" {
  alarm_name          = "${local.green_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors green environment cpu utilization"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.green.name
  }
  
  tags = merge(var.tags, {
    Name        = "${local.green_name}-high-cpu"
    Environment = "green"
  })
}

# CloudWatch alarm for unhealthy hosts in blue environment
resource "aws_cloudwatch_metric_alarm" "blue_unhealthy_hosts" {
  alarm_name          = "${local.blue_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 120
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "This metric monitors unhealthy hosts in blue environment"
  
  dimensions = {
    TargetGroup  = aws_lb_target_group.blue.arn_suffix
    LoadBalancer = aws_lb.web.arn_suffix
  }
  
  tags = merge(var.tags, {
    Name        = "${local.blue_name}-unhealthy-hosts"
    Environment = "blue"
  })
}

# CloudWatch alarm for unhealthy hosts in green environment
resource "aws_cloudwatch_metric_alarm" "green_unhealthy_hosts" {
  alarm_name          = "${local.green_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 120
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "This metric monitors unhealthy hosts in green environment"
  
  dimensions = {
    TargetGroup  = aws_lb_target_group.green.arn_suffix
    LoadBalancer = aws_lb.web.arn_suffix
  }
  
  tags = merge(var.tags, {
    Name        = "${local.green_name}-unhealthy-hosts"
    Environment = "green"
  })
}