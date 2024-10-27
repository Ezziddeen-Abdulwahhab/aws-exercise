resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/webapp"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = 60
  statistic          = "Average"
  threshold          = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.webapp_cluster.name
    ServiceName = aws_ecs_service.webapp_service.name
  }

  alarm_actions = [
    aws_sns_topic.webapp_alerts_topic.arn,
  ]
}

resource "aws_sns_topic" "webapp_alerts_topic" {
  name = "ecs-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.webapp_alerts_topic.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}

