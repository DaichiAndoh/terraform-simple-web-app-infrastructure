# ==================================
# ecs
# ==================================
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.user}-${var.project}-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.user}-${var.project}-ecs-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "sample-app"
      image     = var.ecr_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name  = "COGNITO_USER_POOL_ID"
          value = aws_cognito_user_pool.user_pool.id
        },
        {
          name  = "COGNITO_CLIENT_ID"
          value = aws_cognito_user_pool_client.client.id
        },
        {
          name  = "MYSQL_SERVER"
          value = aws_db_instance.rds_instance.address
        },
        {
          name  = "MYSQL_USER"
          value = "${var.db_username}"
        },
        {
          name  = "MYSQL_PASSWORD"
          value = "${var.db_password}"
        },
        {
          name  = "MYSQL_DATABASE"
          value = "${var.db_name}"
        },
        {
          name  = "MYSQL_PORT"
          value = "${tostring(var.db_port)}"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.sample_app_logs.name
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.user}-${var.project}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.private_subnet_1a.id,
      aws_subnet.private_subnet_1c.id
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = "sample-app"
    container_port   = 80
  }
}
