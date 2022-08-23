terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

# Define sec group for the EC2 instance
resource "aws_security_group" "aws-striim-sg" {
  name        = "dev-striim-sg"
  description = "Allow incoming connections"
  vpc_id      =  "vpc-104df574"   
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }
 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections (Linux)"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  
 }

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["self"]  
  filter {
    name   = "name"
    values = ["dev-centos-striim*"]
  }
}

# Create EC2 Instance
resource "aws_instance" "aws-ec2-server" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.vm_instance_type
  subnet_id              = "subnet-d1806f89"
  vpc_security_group_ids = [aws_security_group.aws-striim-sg.id]
  source_dest_check      = false
  key_name               = "simson_dev"
  associate_public_ip_address = var.vm_associate_public_ip_address
  
  # root disk
  root_block_device {
    volume_size           = var.vm_root_volume_size
    volume_type           = var.vm_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.vm_data_volume_size
    volume_type           = var.vm_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name = "linux-server-vm"
  }
}
