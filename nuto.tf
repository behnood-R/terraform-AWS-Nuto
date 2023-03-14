# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

# Define the subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "private-1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "private-2"
  }
}

# Define the security groups
resource "aws_security_group" "frontend" {
  name_prefix = "frontend-"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}

resource "aws_security_group" "backend" {
  name_prefix = "backend-"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 33001
    to_port   = 33001
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

# Define the EC2 instances
resource "aws_instance" "backend-1" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-1.id
  vpc_security_group_ids = [aws_security_group.backend.id]
  tags = {
    Name = "BK1"
  }
}

resource "aws_instance" "backend-2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-2.id
  vpc_security_group_ids = [aws_security_group.backend.id]
  tags = {
    Name = "BK2"
  }
}

resource "aws_instance" "frontend" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.frontend.id]
  tags = {
    Name = "FR1"
  }
}

# Define the NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

# Define the S3 buckets
resource "aws_s3_bucket" "bucket1" {
  bucket = "my-bucket-1"
}

resource "aws_s3_bucket" "bucket2" {
  bucket = "my-bucket-2"
}
