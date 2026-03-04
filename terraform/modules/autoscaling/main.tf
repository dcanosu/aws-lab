resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = var.desired
  max_size            = var.max
  min_size            = var.min
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg"
    propagate_at_launch = true
  }

  target_group_arns = [var.target_group_arn]
}