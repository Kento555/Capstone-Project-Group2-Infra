###########################################################
######                    VPC                        ######
###########################################################
resource "aws_vpc" "ce-grp-2-vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-ce-grp-2-vpc"
  }
}

#create internet gateway
resource "aws_internet_gateway" "ce-grp-2-igw" {
  vpc_id = aws_vpc.ce-grp-2-vpc.id

  tags = {
    Name = "${var.env}-ce-grp-2-igw"
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
    Name = "${var.env}-ce-grp-2-private"

  }
}

resource "aws_route_table" "ce-grp-2-public" {
  vpc_id = aws_vpc.ce-grp-2-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ce-grp-2-igw.id
  }

  tags = {
    Name = "${var.env}-ce-grp-2-public"
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

###########################################################
######                  Subnets                      ######
###########################################################


resource "aws_subnet" "ce-grp-2-private_zone1" {
  vpc_id            = aws_vpc.ce-grp-2-vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = var.zone1

  tags = {
    "Name"                                             = "${var.env}-private-${var.zone1}"
    "kubernetes.io/role/internal-elb"                  = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_subnet" "ce-grp-2-private_zone2" {
  vpc_id            = aws_vpc.ce-grp-2-vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = var.zone2

  tags = {
    "Name"                                             = "${var.env}-private-${var.zone2}"
    "kubernetes.io/role/internal-elb"                  = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_subnet" "ce-grp-2-public_zone1" {
  vpc_id                  = aws_vpc.ce-grp-2-vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = var.zone1
  map_public_ip_on_launch = true

  tags = {
    "Name"                                             = "${var.env}-public-${var.zone1}"
    "kubernetes.io/role/elb"                           = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_subnet" "ce-grp-2-public_zone2" {
  vpc_id                  = aws_vpc.ce-grp-2-vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = var.zone2
  map_public_ip_on_launch = true

  tags = {
    "Name"                                             = "${var.env}-public-${var.zone2}"
    "kubernetes.io/role/elb"                           = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}


###########################################################
######                     NAT                       ######
###########################################################

resource "aws_eip" "ce-grp-2-nat" {
  domain = "vpc"

  tags = {
    Name = "${var.env}-ce-grp-2-nat"
  }
}

resource "aws_nat_gateway" "ce-grp-2-nat" {
  allocation_id = aws_eip.ce-grp-2-nat.id
  subnet_id     = aws_subnet.ce-grp-2-public_zone1.id

  tags = {
    Name = "${var.env}-ce-grp-2-nat"
  }

  depends_on = [aws_internet_gateway.ce-grp-2-igw]
}
