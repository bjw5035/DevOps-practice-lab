variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access to bastion"
  type        = string
}

variable "aws_region" {
  description = "AWS region to create resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "devops-practice"
}

variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet in ap-northeast-2a"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_c_cidr" {
  description = "CIDR block for public subnet in ap-northeast-2c"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private subnet in ap-northeast-2a"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_subnet_c_cidr" {
  description = "CIDR block for private subnet in ap-northeast-2c"
  type        = string
  default     = "10.0.12.0/24"
}

variable "availability_zone_a" {
  description = "Availability Zone A"
  type        = string
  default     = "ap-northeast-2a"
}

variable "availability_zone_c" {
  description = "Availability Zone C"
  type        = string
  default     = "ap-northeast-2c"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "bastion-key"
}
