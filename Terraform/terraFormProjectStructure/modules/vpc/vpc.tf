module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "vpc-${var.Environment}"
    cidr = "10.0.0.0/16"

    azs             = ["${var.AWS_REGION}a","${var.AWS_REGION}b","${var.AWS_REGION}c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = false
    enable_vpn_gateway = false

    tags = {
        Terraform = "true"
        Environment = var.Environment
    }
}

output "my_vpc_id" {
    description = "VPC ID"
    value = module.vpc.vpc_id
}

output "public_subnets" {
    description = "list of id of public subnets"
    value = module.vpc.public_subnets
}

output "private_subnets" {
    description = "List of Id of private subnets"
    value = module.vpc.private_subnets
}