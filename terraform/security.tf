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
