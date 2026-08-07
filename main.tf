resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.igw_name
  }
}

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.subnet_1_az
  map_public_ip_on_launch = true
  tags = {
    Name                     = local.public_subnet_1_name
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.subnet_2_az
  map_public_ip_on_launch = true
  tags = {
    Name                     = local.public_subnet_2_name
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "shopease-public-route-table"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_az1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_az1.id
}

resource "aws_route_table_association" "public_az2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_az2.id
}