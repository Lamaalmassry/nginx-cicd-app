provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "backend-bucket-terraform"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainIGW"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Create Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  name   = "ec2sgweb"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2 with ECR Access
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-with-ecr-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecr_policy" {
  name = "allow-ecr-access"
  role = aws_iam_role.ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ecr:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile-with-ecr-access"
  role = aws_iam_role.ec2_role.name
}

# ECR Repository
resource "aws_ecr_repository" "nginx_repo" {
  name                 = "nginx-docker-repo"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
# EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-09115b7bffbe3c5e4" 
  instance_type          = "t2.micro"
  key_name               = "github-key"  
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "My-EC2-Instance"
  }
}

# Outputs
output "instance_id" {
  value     = aws_instance.ec2_instance.id
  sensitive = false
}

output "instance_public_ip" {
  value     = aws_instance.ec2_instance.public_ip
  sensitive = false
}

output "ecr_repository_url" {
  value     = aws_ecr_repository.nginx_repo.repository_url
  sensitive = false
}

output "ecr_repository_name" {
  value     = aws_ecr_repository.nginx_repo.name
  sensitive = false
}
