resource "aws_cloudwatch_metric_alarm" "up" {
  alarm_name          = "LB Scale Up"
  alarm_description   = "Scale up an instance when CPU utilization is great than 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.auto-scaling.id}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scaleup.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "down" {
  alarm_name          = "LB Scale Down"
  alarm_description   = "Scale up an instance when CPU utilization is lesser than 50%"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.auto-scaling.id}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scaledown.arn}"]
}