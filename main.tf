/*
 * # Informer Datahub Tunnel
 *
 * An ECS based SSH reverse proxy used as a secure tunnel to the Entrinsik
 * Datahub.
 *
 * ## Troubleshooting
 *
 * It is possible to enter the ECS container running the tunnel with the
 * following command:
 *
 * ```
 * aws ecs execute-command \
 *     --region <REGION> \
 *     --cluster <CLUSTER> \
 *     --task <TASK_ID> \
 *     --container ssh-reverse-tunnel \
 *     --command "/bin/bash" \
 *     --interactive
 * ```
 */

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name = var.identifier

  tags = {
    Name = var.identifier
  }
}

resource "aws_security_group" "this" {
  name   = "${var.identifier}-service"
  description = "Manage access to the ECS service"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow outgoing connections from the ECS task containers to any TCP destination"
  security_group_id = aws_security_group.this.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.datahub_cidrs
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "cloudwatch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.identifier
  assume_role_policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "task" {
  statement {
    actions = ["ssm:GetParameter"]
    effect  = "Allow"
    resources = [
      data.aws_ssm_parameter.ssh_private_key.arn,
      data.aws_ssm_parameter.ssh_public_key.arn,
      data.aws_ssm_parameter.ssh_certificate.arn
    ]
  }
  # TODO(jkinred): tfsec fails this policy due to BatchCheckLayerAvailability wildcard
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    effect  = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name = var.identifier
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.task.json
}

resource "aws_ecs_cluster" "this" {
  name = var.identifier

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Created with aws ssm put-parameter --name $name --value $value --type SecureString
data "aws_ssm_parameter" "ssh_private_key" {
  name = "${var.tunnel_parameter_store_prefix}-ssh_private_key"
}

# Created with aws ssm put-parameter --name $name --value $value --type String
data "aws_ssm_parameter" "ssh_public_key" {
  name = "${var.tunnel_parameter_store_prefix}-ssh_public_key"
}

# Created with aws ssm put-parameter --name $name --value $value --type SecureString
data "aws_ssm_parameter" "ssh_certificate" {
  name = "${var.tunnel_parameter_store_prefix}-ssh_certificate"
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.identifier
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn

  container_definitions = jsonencode([{
    name      = "ssh-reverse-tunnel"
    image     = "${var.image_name}:${var.image_tag}"
    essential = true
    environment = [
      {
        name  = "PUBKEY"
        value = data.aws_ssm_parameter.ssh_public_key.value
      },
      {
        name  = "PRIVKEY"
        value = data.aws_ssm_parameter.ssh_private_key.value
      },
      {
        name  = "CERT"
        value = data.aws_ssm_parameter.ssh_certificate.value
      },
      {
        name  = "HUB_PORT"
        value = tostring(var.datahub_port)
      },
      {
        # The IP of the destination server
        name  = "DEST_SERVER"
        value = var.datasource_address
      },
      {
        # The port the database service is listening on
        name  = "DEST_PORT"
        value = tostring(var.datasource_port)
      }
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = var.identifier
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name                               = var.identifier
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  enable_execute_command             = true
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    subnets          = var.ecs_service_subnets
    assign_public_ip = false
    security_groups  = concat([aws_security_group.this.id], var.ecs_security_groups)
  }

  tags = {
    Name = var.identifier
  }
}
