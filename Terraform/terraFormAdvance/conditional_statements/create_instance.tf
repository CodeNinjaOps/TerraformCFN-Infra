provider "aws" {
    region = var.AWS_REGION
}

module "ec2_cluster" {
    source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"

    name = "my_cluster"
    ami = "ami-001"
    instance_type = "t2.small"
    subnet_id = "subnet-001"
    instance_count = var.environment == "Production" ? 2 : 1

    tags = {
        Terraform = "true"
        Environment = var.environment
    }
}