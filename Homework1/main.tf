# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PROVIDERS
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.13.0"
    }
  }
}

provider "aws" {
    profile = "default"
    region  = var.aws_region
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY NETWORKING (VPC)
# ----------------------------------------------------------------------------------------------------------------------
module "network" {
    source = "./modules/network"

    vpc_cider_block      = "10.0.0.0/16"
    consul_servers_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    app_servers_subnets_cidr = ["10.0.4.0/24"]
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY APPLICATION STATES (EC2 AND LB)
# ----------------------------------------------------------------------------------------------------------------------
module "application" {
    source = "./modules/application"

    instance_type                = "t2.micro"
    key_name                     = "test-keypair"
    vpc-id                       = module.network.vpc-id
    consul-servers-subnets       = module.network.consul-servers-subnets
    app-servers-subnets          = module.network.app-servers-subnets
    user-data-app                = local.nginx
    user-data-consul             = local.consul
}