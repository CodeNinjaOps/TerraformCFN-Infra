variable "cidr_block" {
    description = "cdir block for the vpc"
    default = "10.0.1.0/16"
}

variable "cidr_subnet" {
    description = "cdir for the subnet"
    default = "10.1.0.0/24"
}

variable "environment_tag" {
    description = "environment tag"
    default = "Production"
}

variable "availability_zone" {
    description = "avaiablity zone the subnet need to created"
    default = "us-east-2a"
}