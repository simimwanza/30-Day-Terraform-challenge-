# Blue/Green deployment module for zero-downtime deployments

locals {
  blue_name  = "${var.name_prefix}-blue"
  green_name = "${var.name_prefix}-green"
  
  # Determine active environment based on deployment_state
  active_environment  = var.deployment_state == "blue" ? "blue" : "green"
  inactive_environment = var.deployment_state == "blue" ? "green" : "blue"
  
  # Set traffic distribution
  blue_weight  = var.deployment_state == "blue" ? 100 - var.traffic_distribution : var.traffic_distribution
  green_weight = var.deployment_state == "green" ? 100 - var.traffic_distribution : var.traffic_distribution
  
  # User data templates
  blue_user_data = templatefile("${path.module}/user_data.sh.tpl", {
    environment = "blue"
    app_version = var.blue_app_version
    color       = "#0000FF"
  })
  
  green_user_data = templatefile("${path.module}/user_data.sh.tpl", {
    environment = "green"
    app_version = var.green_app_version
    color       = "#00FF00"
  })
}

# Target group for blue environment
resource "aws_lb_target_group" "blue" {
  name     = "${local.blue_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
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
    Name        = "${local.blue_name}-tg"
    Environment = "blue"
  })
}

# Target group for green environment
resource "aws_lb_target_group" "green" {
  name     = "${local.green_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
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
    Name        = "${local.green_name}-tg"
    Environment = "green"
  })
}

# Launch template for blue environment
resource "aws_launch_template" "blue" {
  name_prefix   = "${local.blue_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [var.security_group_id]
  
  user_data = base64encode(local.blue_user_data)
  
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
      Name        = "${local.blue_name}-instance"
      Environment = "blue"
      AppVersion  = var.blue_app_version
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
  
  vpc_security_group_ids = [var.security_group_id]
  
  user_data = base64encode(local.green_user_data)
  
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
      Name        = "${local.green_name}-instance"
      Environment = "green"
      AppVersion  = var.green_app_version
    })
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for blue environment
resource "aws_autoscaling_group" "blue" {
  name                = "${local.blue_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids
  
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
  vpc_zone_identifier = var.subnet_ids
  
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

# Listener for HTTP traffic with weighted target groups
resource "aws_lb_listener" "http" {
  load_balancer_arn = var.load_balancer_arn
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