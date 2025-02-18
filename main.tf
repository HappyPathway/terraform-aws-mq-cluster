resource "aws_security_group" "mq" {
  count       = var.create_security_group && var.security_group_config != null ? 1 : 0
  name        = coalesce(var.security_group_config.name, "${var.broker_name}-mq-sg")
  description = coalesce(var.security_group_config.description, "Security group for MQ broker ${var.broker_name}")
  vpc_id      = var.security_group_config.vpc_id

  dynamic "ingress" {
    for_each = var.security_group_config.ingress_rules != null ? var.security_group_config.ingress_rules : []
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      security_groups  = ingress.value.security_groups
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = coalesce(var.security_group_config.name, "${var.broker_name}-mq-sg")
  })
}

resource "aws_iam_role" "cloudwatch" {
  count = var.cloudwatch_logging_enabled && var.create_cloudwatch_log_role ? 1 : 0
  name  = "${var.broker_name}-mq-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "mq.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cloudwatch" {
  count = var.cloudwatch_logging_enabled && var.create_cloudwatch_log_role ? 1 : 0
  name  = "${var.broker_name}-cloudwatch-policy"
  role  = aws_iam_role.cloudwatch[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

resource "aws_mq_broker" "main" {
  broker_name        = var.broker_name
  engine_type        = try(var.broker_config.engine_type, "ActiveMQ")
  engine_version     = var.broker_config.engine_version
  host_instance_type = var.broker_config.host_instance_type
  deployment_mode    = try(var.broker_config.deployment_mode, "SINGLE_INSTANCE")
  storage_type      = var.broker_config.storage_type
  
  authentication_strategy  = var.broker_config.authentication_strategy
  auto_minor_version_upgrade = var.broker_config.auto_minor_version_upgrade
  publicly_accessible     = var.broker_config.publicly_accessible
  security_groups         = concat(
    coalesce(var.broker_config.security_groups, []),
    var.create_security_group && var.security_group_config != null ? [aws_security_group.mq[0].id] : []
  )
  subnet_ids             = var.broker_config.subnet_ids

  dynamic "user" {
    for_each = var.user_config
    content {
      username       = user.value.username
      password       = user.value.password
      groups        = user.value.groups
      console_access = user.value.console_access
    }
  }

  dynamic "maintenance_window_start_time" {
    for_each = var.maintenance_window_config != null ? [var.maintenance_window_config] : []
    content {
      day_of_week = maintenance_window_start_time.value.day_of_week
      time_of_day = maintenance_window_start_time.value.time_of_day
      time_zone   = maintenance_window_start_time.value.time_zone
    }
  }

  dynamic "logs" {
    for_each = var.logs_config != null ? [var.logs_config] : []
    content {
      general = var.cloudwatch_logging_enabled
      audit   = var.cloudwatch_logging_enabled
    }
  }

  dynamic "encryption_options" {
    for_each = var.encryption_config != null ? [var.encryption_config] : []
    content {
      use_aws_owned_key = encryption_options.value.use_aws_owned_key
      kms_key_id        = encryption_options.value.kms_key_id
    }
  }

  tags = var.tags

  depends_on = [aws_iam_role.cloudwatch]
}