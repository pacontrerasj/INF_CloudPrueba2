# ──────────────────────────────────────────────
# ALB - Application Load Balancer (Alta Disponibilidad)
# ──────────────────────────────────────────────

resource "aws_lb" "technova" {
  name               = "alb-${var.proyecto}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]

  subnets = [
    var.subnet_ids[0],
    var.subnet_ids[1],
  ]

  tags = {
    Name = "alb-${var.proyecto}"
  }
}

resource "aws_lb_target_group" "technova" {
  name     = "tg-${var.proyecto}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "tg-${var.proyecto}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.technova.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.technova.arn
  }
}

# ──────────────────────────────────────────────
# COMPUTE - Launch Template + Auto Scaling Group
# ──────────────────────────────────────────────

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "technova" {
  name          = "lt-${var.proyecto}"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_ec2_id]
  }

  user_data = base64encode(file("${path.module}/user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-${var.proyecto}-asg"
    }
  }

  tags = {
    Name = "lt-${var.proyecto}"
  }
}

resource "aws_autoscaling_group" "technova" {
  name = "asg-${var.proyecto}"

  min_size         = 2
  desired_capacity = 2
  max_size         = 3

  vpc_zone_identifier = [
    var.subnet_ids[0],
    var.subnet_ids[1],
  ]

  target_group_arns = [aws_lb_target_group.technova.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.technova.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ec2-${var.proyecto}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Proyecto"
    value               = "TechNova"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "policy-cpu-${var.proyecto}"
  autoscaling_group_name = aws_autoscaling_group.technova.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
