module "dev-vpc-qa" {
    source = "../../custom_vpc"

    vpc_name = "dev-vpc-qa-01"
    cidr = "10.0.1.0/24"
    enable_dns_hostnames = "false"
    enable_dns_support = "true"
    enable_ipv6 = "false"
    vpcenvironment = "Development-QA-Engineering"
    AWS_REGION = "us-east-1"
}