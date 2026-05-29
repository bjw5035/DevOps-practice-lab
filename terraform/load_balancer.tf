resource "aws_security_group" "alb" {

  vpc_id      = aws_vpc.main.id
  name        = "alb-sg"
  description = "Security Group for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "alb-sg"
  }
}




resource "aws_lb" "main" {
  name               = "aws-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  # subnets            = ["public_a", "public_c"]
  # 수정 
  subnets = [aws_subnet.public_a.id, aws_subnet.public_c.id]

  tags = {
    Name = "main-alb"
  }

}

# Target Group
resource "aws_lb_target_group" "main" {

  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "main-tg"
  }
}

# Listener (HTTP 80 받아서 Target Groupdmfh forward)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
