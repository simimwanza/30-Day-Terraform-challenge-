output "blue_target_group_arn" {
  description = "ARN of the blue target group"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "ARN of the green target group"
  value       = aws_lb_target_group.green.arn
}

output "blue_asg_name" {
  description = "Name of the blue Auto Scaling Group"
  value       = aws_autoscaling_group.blue.name
}

output "green_asg_name" {
  description = "Name of the green Auto Scaling Group"
  value       = aws_autoscaling_group.green.name
}

output "active_environment" {
  description = "Currently active environment (blue or green)"
  value       = local.active_environment
}

output "blue_weight" {
  description = "Current traffic weight for blue environment"
  value       = local.blue_weight
}

output "green_weight" {
  description = "Current traffic weight for green environment"
  value       = local.green_weight
}