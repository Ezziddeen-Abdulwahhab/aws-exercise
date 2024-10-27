resource "aws_ecs_cluster" "webapp_cluster" {
  name = "webapp-cluster"
}

resource "aws_ecs_task_definition" "webapp_task_definition" {
  family                   = "webapp-task-family"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
  {
    name = "webapp-container",
    image = "717279720613.dkr.ecr.eu-north-1.amazonaws.com/webapp:latest",
    essential = true,
    portMappings = [
      {
        containerPort = 8080,
        hostPort = 8080
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/webapp"
        awslogs-region        = "eu-north-1"
        awslogs-stream-prefix = "ecs"
      }
     }
  }
])
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "dynamodb-access-policy"
  description = "Allows access to DynamoDB tables for ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = "arn:aws:dynamodb:eu-north-1:717279720613:table/webapp-table"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_dynamodb_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

resource "aws_ecs_service" "webapp_service" {
  name            = "webapp-service"
  cluster         = aws_ecs_cluster.webapp_cluster.id
  task_definition = aws_ecs_task_definition.webapp_task_definition.arn
  launch_type     = "EC2"
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.webapp_subnet.id]
    security_groups = [aws_security_group.webapp_security_group.id]
    assign_public_ip = true
  }
}
