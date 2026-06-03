resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

# === Public Subnets (외부 접근용: ALB, Bastion) ===
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet-a"
    Tier = "public"
  })
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_c_cidr
  availability_zone       = var.availability_zone_c
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet-c"
    Tier = "public"
  })
}

# === Private Subnets (내부 전용: 앱 EC2, DB) ===
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zone_a

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-subnet-a"
    Tier = "private"
  })
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zone_c

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-subnet-c"
    Tier = "private"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

# === Public Route Table (퍼블릭 표지판) ===
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  # 0.0.0.0/0 (모든 외부) → IGW로 보내라
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
    Tier = "public"
  })
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
