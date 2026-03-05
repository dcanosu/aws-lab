resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = var.asg_name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-metrics"

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1: RAM
      {
        type = "metric", x = 0, y = 0, width = 8, height = 6
        properties = {
          metrics = [
            [ "CWAgent", "mem_used_percent", "AutoScalingGroupName", "${var.asg_name}" ] 
          ]
          period = 60, stat = "Average", region = "us-east-1", title = "RAM (%)", yAxis = { left = { min = 0, max = 100 } }
        }
      },
      # Widget 2: CPU
      {
        type = "metric", x = 8, y = 0, width = 8, height = 6
        properties = {
          metrics = [ [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${var.asg_name}" ] ]
          period = 60, stat = "Average", region = "us-east-1", title = "CPU (%)"
        }
      },
      # Widget 3: Requests
      {
        type = "metric", x = 16, y = 0, width = 8, height = 6
        properties = {
          metrics = [ [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.alb_arn_suffix}" ] ]
          period = 60, stat = "Sum", region = "us-east-1", title = "HTTP Requests"
        }
      }
    ]
  })
}
