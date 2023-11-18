variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The ID of the Ubuntu AMI"
  type        = string
  default     = "ami-0fc5d935ebf8bc3bc"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "m4.large"
}

variable "volume_size" {
  description = "Size of the storage volume"
  type        = number
  default     = 8
}

variable "availability_zone" {
  description = "The AWS availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "SG"
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
