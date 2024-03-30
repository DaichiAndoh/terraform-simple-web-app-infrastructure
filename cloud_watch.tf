# ==================================
# cloud watch log
# ==================================
resource "aws_cloudwatch_log_group" "sample_app_logs" {
  name              = "/ecs/${var.user}/${var.project}/sample-app"
  retention_in_days = 7
}
