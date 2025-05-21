resource "aws_eip" "ce-grp-2-nat" {
  domain = "vpc"

  tags = {
    Name = "${local.env}-ce-grp-2-nat"
  }
}

resource "aws_nat_gateway" "ce-grp-2-nat" {
  allocation_id = aws_eip.ce-grp-2-nat.id
  subnet_id     = aws_subnet.ce-grp-2-public_zone1.id

  tags = {
    Name = "${local.env}-ce-grp-2-nat"
  }

  depends_on = [aws_internet_gateway.ce-grp-2-igw]
}