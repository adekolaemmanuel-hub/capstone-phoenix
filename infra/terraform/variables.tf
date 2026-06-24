variable "aws_region" {
  default = "us-east-1"
}

variable "project" {
  default = "capstone-phoenix"
}

variable "environment" {
  default = "prod"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "ami" {
  description = "Ubuntu 22.04 AMI for us-east-1"
  default     = "ami-0c7217cdde317cfec"
}

variable "key_name" {
  description = "Name of your EC2 key pair"
  type        = string
}
