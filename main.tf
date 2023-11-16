provider "aws" {
  region = var.aws_region  # Replace with your AWS region
}

resource "aws_instance" "example" {
  ami           = var.ami_id  # Replace with your Ubuntu AMI ID
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size  # Replace with your desired volume size
  }

  availability_zone = var.availability_zone  # Replace with your AWS availability zone
}

resource "aws_security_group" "example" {
  name        = var.sg_name
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks  # Replace with your desired CIDR blocks
  }
}

output "instance_id" {
  value = aws_instance.example.id
}
