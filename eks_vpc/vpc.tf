terraform {
  backend "s3" {
    bucket         = "dev-terraform-remote-state-123"
    region         = "us-east-1"
    key = "vpc_state"
  }
}



resource "aws_vpc" "eks-dev-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.eks-dev-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
   map_public_ip_on_launch = true

  tags = {
    Name = "eks-subnet-1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.eks-dev-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-subnet-2"
  }
}

resource "aws_subnet" "subnet-3" {
  vpc_id     = aws_vpc.eks-dev-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-subnet-3"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.main-rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.main-rt.id
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnet-3.id
  route_table_id = aws_route_table.main-rt.id
}

resource "aws_route_table" "main-rt" {
  vpc_id = aws_vpc.eks-dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "eks-outbound"
  }
}

resource "aws_route" "outbound_route" {
  route_table_id              = aws_route_table.main-rt.id
  destination_cidr_block    = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id

}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks-dev-vpc.id

  tags = {
    Name = "eks-IGW"
  }
}