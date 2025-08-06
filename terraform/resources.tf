resource "aws_s3_bucket" "qmkdesign-backend-backup-bucket" {
  provider = aws.p1
  bucket   = "qmkdesign-backend-backup-bucket"

  tags = {
    Name = "qmkdesign-backend-backup-bucket"
  }
}

resource "aws_dynamodb_table" "user-data" {
  provider     = aws.p1
  name         = "user-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
}

resource "aws_ecr_repository" "qmkdesign-backend" {
  provider = aws.p1
  name = "qmkdesign-backend"
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  provider   = aws.p1
  repository = aws_ecr_repository.qmkdesign-backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Only keep 2 images in ECR"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 2
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_vpc" "default" {
  provider = aws.p1
  default = true
}

data "aws_subnets" "default" {
  provider = aws.p1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "alb_sg" {
  provider    = aws.p1
  name        = "qmkdesign-backend-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "fargate_sg" {
  provider    = aws.p1
  name        = "qmkdesign-backend-fargate-sg"
  description = "Security group for Fargate tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 8080  
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "backend_alb" {
  provider           = aws.p1
  name               = "qmkdesign-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "backend_tg" {
  provider    = aws.p1
  name        = "qmkdesign-backend-tg"
  port        = 8080  
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"  
    matcher             = "200"
  }
}

resource "aws_lb_listener" "backend_listener" {
  provider          = aws.p1
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_ecs_cluster" "backend_cluster" {
  provider = aws.p1
  name     = "qmkdesign-backend-cluster"
}

resource "aws_cloudwatch_log_group" "backend_logs" {
  provider              = aws.p1
  name                  = "/ecs/qmkdesign-backend"
  retention_in_days     = 7
}

resource "aws_ecs_task_definition" "backend_task" {
  provider                 = aws.p1
  family                   = "qmkdesign-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"    
  memory                   = "1024"   
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "qmkdesign-backend"
      image = "${aws_ecr_repository.qmkdesign-backend.repository_url}:latest"
      
      portMappings = [
        {
          containerPort = 8080  
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "DYNAMODB_TABLE"
          value = aws_dynamodb_table.user-data.name
        },
        {
          name  = "S3_BUCKET"
          value = aws_s3_bucket.qmkdesign-backend-backup-bucket.id
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      ephemeralStorage = {
        sizeInGiB = 30  
      }
    }
  ])
}

resource "aws_ecs_service" "backend_service" {
  provider        = aws.p1
  name            = "qmkdesign-backend-service"
  cluster         = aws_ecs_cluster.backend_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1  
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.fargate_sg.id]
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "qmkdesign-backend"
    container_port   = 8080  
  }

  depends_on = [aws_lb_listener.backend_listener]
}

output "backend_url" {
  value = "http://${aws_lb.backend_alb.dns_name}"
}

