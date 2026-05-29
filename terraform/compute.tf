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
