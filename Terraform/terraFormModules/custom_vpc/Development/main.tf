module "dev-vpc" {
    source = "../../custom_vpc"

    vpc_name = "dev-vpc-01"
    cidr = "10.0.2.0/24"
    enable_dns_hostnames = "false"
    enable_dns_support = "true"
    enable_ipv6 = "true"
    vpcenvironment = "Development-Engineering"
}