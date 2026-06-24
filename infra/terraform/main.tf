terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source      = "./modules/network"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "security_group" {
  source     = "./modules/security_group"
  project    = var.project
  vpc_id     = module.network.vpc_id
  my_ip      = var.my_ip
}

module "compute" {
  source            = "./modules/compute"
  project           = var.project
  ami               = var.ami
  key_name          = var.key_name
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.security_group.sg_id
}
