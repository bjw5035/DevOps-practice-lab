terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "devops-practice-vpc"
  }
}

# === Public Subnets (외부 접근용: ALB, Bastion) ===
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
    Tier = "public"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-c"
    Tier = "public"
  }
}

# === Private Subnets (내부 전용: 앱 EC2, DB) ===
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private-subnet-a"
    Tier = "private"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "private-subnet-c"
    Tier = "private"
  }
}

# === Internet Gateway (단지 정문) ===
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-practice-igw"
  }
}

# === Public Route Table (퍼블릭 표지판) ===
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # 0.0.0.0/0 (모든 외부) → IGW로 보내라
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
    Tier = "public"
  }
}

# === Public Subnet과 Route Table 연결 ===
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "bastion" {

  vpc_id      = aws_vpc.main.id
  description = "Security Group for Bastion host"
  name        = "bastion-sg"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
    description = "SSH"
  }

  tags = {
    Name = "bastion-sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
}


resource "aws_instance" "bastion" {

  ami                    = "ami-0533c7c245a0ee297"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = "bastion-key"

  tags = {
    Name = "bastion_host"
  }

}


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

