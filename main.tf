#VPC
resource "aws_vpc" "aws-networking-vpc" {
  cidr_block = "10.0.0.0/16"

   tags = {
    Name = "aws-networking-vpc"
  }
}

#Private subnet 1
resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.aws-networking-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private 1"
  }
}

#Private subnet 2
resource "aws_subnet" "private-2" {
  vpc_id     = aws_vpc.aws-networking-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private 2"
  }
}

#Public subnet 1
resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.aws-networking-vpc.id
  cidr_block = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public 1"
  }
}

#Public subnet 2
resource "aws_subnet" "public-2" {
  vpc_id     = aws_vpc.aws-networking-vpc.id
  cidr_block = "10.0.102.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public 2"
  }
}

