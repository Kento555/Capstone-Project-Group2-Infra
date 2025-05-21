# create vpc
resource "aws_vpc" "ce-grp-2-vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env}-ce-grp-2-vpc"
  }
}

#create internet gateway
resource "aws_internet_gateway" "ce-grp-2-igw" {
  vpc_id = aws_vpc.ce-grp-2-vpc.id

  tags = {
    Name = "${local.env}-ce-grp-2-igw"
  }
}

#create route table
resource "aws_route_table" "ce-grp-2-private" {
  vpc_id = aws_vpc.ce-grp-2-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ce-grp-2-nat.id
  }

  tags = {
    Name = "${local.env}-ce-grp-2-private"

  }
}

resource "aws_route_table" "ce-grp-2-public" {
  vpc_id = aws_vpc.ce-grp-2-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ce-grp-2-igw.id
  }

  tags = {
    Name = "${local.env}-ce-grp-2-public"
  }
}

resource "aws_route_table_association" "ce-grp-2-private_zone1" {
  subnet_id      = aws_subnet.ce-grp-2-private_zone1.id
  route_table_id = aws_route_table.ce-grp-2-private.id
}

resource "aws_route_table_association" "ce-grp-2-private_zone2" {
  subnet_id      = aws_subnet.ce-grp-2-private_zone2.id
  route_table_id = aws_route_table.ce-grp-2-private.id
}

resource "aws_route_table_association" "ce-grp-2-public_zone1" {
  subnet_id      = aws_subnet.ce-grp-2-public_zone1.id
  route_table_id = aws_route_table.ce-grp-2-public.id
}

resource "aws_route_table_association" "ce-grp-2-public_zone2" {
  subnet_id      = aws_subnet.ce-grp-2-public_zone2.id
  route_table_id = aws_route_table.ce-grp-2-public.id
}
