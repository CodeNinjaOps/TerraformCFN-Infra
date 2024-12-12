module "dev-vpc" {
    source = "../modules/vpc"

    Environment = var.Env
    AWS_REGION = var.AWS_REGION
}

module "dev-instance" {
    source = "../modules/instance"

    Environment = var.Env
    AWS_REGION = var.AWS_REGION
    VPC_ID = module.dev-vpc.my_vpc_id
    PUBLIC_SUBNET = module.dev-vpc.public_subnets
}

provider "aws" {
    region = var.AWS_REGION
}