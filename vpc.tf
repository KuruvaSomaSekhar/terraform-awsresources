resource "aws_vpc" "demo" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "demo"
  }
}

resource "aws_subnet" "public-sn-1a" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sn-1a"
  }
}

resource "aws_subnet" "private-sn-1a" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = "10.0.0.64/26"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-sn-1a"
  }
}

resource "aws_subnet" "public-sn-1b" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = "10.0.0.128/26"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public-sn-1b"
  }
}

resource "aws_subnet" "private-sn-1b" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = "10.0.0.192/26"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-sn-1b"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public-sn-1a" {
  subnet_id      = aws_subnet.public-sn-1a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-sn-1b" {
  subnet_id      = aws_subnet.public-sn-1b.id
  route_table_id = aws_route_table.public-rt.id
}

# Private Routing 

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "pvt-sn-1a" {
  subnet_id      = aws_subnet.private-sn-1a.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "pvt-sn-1b" {
  subnet_id      = aws_subnet.private-sn-1b.id
  route_table_id = aws_route_table.private-rt.id
}

# NAT 

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-sn-1a.id

  tags = {
    Name = "Demo-NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}