resource "aws_vpc" "vpc1" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "terraform-vpc"
    }
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.vpc1.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true
    tags = {
        Name = "terraform-subnet"
    }
}

resource "aws_internet_gateway" "igw1" {
    vpc_id = aws_vpc.vpc1.id
    tags = {
        Name = "terraform-igw"
    }
}

resource "aws_route_table" "route_table1" {
    vpc_id = aws_vpc.vpc1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw1.id
    }
    tags = {
        Name = "terraform-route-table"
    }
}
