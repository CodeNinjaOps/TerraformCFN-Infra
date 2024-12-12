variable "AWS_ACCESS_KEY" {
    type = string
    default = "DAHAIAALKJHTRVKLOIBJ"
}

variable "AWS_REGION" {
    type = string
    default = "us-east-1"
}

variable "vpc_name" {
    description = "name on the vpc to identify"
    type  = string
    default = ""
}

variable "cidr" {
    description = "The cidr block of the vpc"
    type = string
    default = "0.0.0.0/0"
}

variable "instance_tenancy" {
    description = "tendency options to instance launched in the vpc"
    type = string 
    default = "default"
}

variable "enable_dns_hostnames" {
    description = "should be true to enabled dns hostname in the vpc"
    type = string 
    default = "false"
}

variable "enable_dns_support" {
    description = "should be true to enabled dns support in the vpc"
    type = string
    default = "true"
}

variable "enable_ipv6" {
    description = "request aws provider for and ipv6 block"
    type = bool
    default = false
}

variable "vpcenvironment" {
    description = "aws vpc environment name"
    type = string
    default = "Development"
}