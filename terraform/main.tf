terraform {
required_providers {
aws = {
source = "hashicorp/aws"
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
