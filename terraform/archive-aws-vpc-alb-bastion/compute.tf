resource "aws_instance" "bastion" {

  ami                    = "ami-0533c7c245a0ee297"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.key_name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vastion"
  })

}
