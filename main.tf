# creating a VPC
resource "aws_vpc" "test_VPC" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Test VPC with Terraform"
  }
}

# Creating a SUB NET 
resource "aws_subnet" "terraform_public_subnet" {
  vpc_id                  = aws_vpc.test_VPC.id
  cidr_block              = "0.0.0.0/0" #public IP or All IPs
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-2a"
  tags = {
    Name = "terraform-public-subnet"
  }
}

#Creating a Internet Geteway
resource "aws_internet_gateway" "Terraform_Internet_gateway" {
  vpc_id = aws_vpc.test_VPC.id

  tags = {
    Name : "Terrafrom InterNet gateway"
  }
}

#creating a route table
resource "aws_route_table" "terraform_route_table" {
  vpc_id = aws_vpc.test_VPC.id

  tags = {
    Name : "terraform_route_table"
  }
}

#creating a Internet getway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.terraform_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Terraform_Internet_gateway.id
}

#Intergrating router subnet with route table
resource "aws_route_table_association" "terraform_route_table_association" {
  subnet_id      = aws_subnet.terraform_public_subnet.id
  route_table_id = aws_route_table.terraform_route_table.id

}

#creating a security Group 
resource "aws_security_group" "terraform_sg" {
  name        = "terraform-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_VPC.id

}

#Creating a Egress rule 
resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  #from_port         = 0
  ip_protocol = "-1"
  #to_port           = 0
}

#Creating a Ingress rule 
resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0" # Replace it with your public IP or All IPs
  #from_port         = 0
  ip_protocol = "-1"
  #to_port           = 0
}


#Associating ssh key 
resource "aws_key_pair" "terraform_auth" {
  key_name   = "tenzo_key"
  public_key = file("~/.ssh/tenzo.pub")
}

#Creating a EC2 Instace 
resource "aws_instance" "ec2-terraform" {
  instance_type          = "t3.micro"
  ami                    = data.aws_ami.ubuntu_AMI.id
  key_name               = aws_key_pair.terraform_auth.id
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  subnet_id              = aws_subnet.terraform_public_subnet.id
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name : "Terraform EC2"
  }

}


