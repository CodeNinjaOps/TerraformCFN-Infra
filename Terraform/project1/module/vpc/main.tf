# get the available zone of the region
data "aws_availability_zones" "available" {
    state = "available"
}

# main vpc 

resource "aws_vpc" "levelup_vpc" {
    cidr_block = var.VPC_CIDR_BLOCK
    enable_dns_hostnames = "true"
    enable_dns_support =    "true"

    tags = {
        name = "${var.ENVIRONMENT}-vpc"
    }
}

# public subnet 

# public subnet 1 

resource "aws_subnet" "levelup_public_subnet_1" {
    vpc_id = aws_vpc.levelup_vpc.id
    cidr_block = var.LEVELUP_PUBLIC_SUBNET1_CIDR_BLOCK
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = "true"

    tags = {
        name = "${var.ENVIRONMENT}-levelup-public-subnet1"
    }
}

# public subnet 2 

resource "aws_subnet" "levelup_public_subnet_2" {
    vpc_id = aws_vpc.levelup_vpc.id
    cidr_block = var.LEVELUP_PUBLIC_SUBNET2_CIDR_BLOCK
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = "true"

    tags = {
        name = "${var.ENVIRONMENT}-levelup-public-subnet2"
    }
}

# private subnet 

# private subnet 1 

resource "aws_subnet" "levelup_private_subnet_1" {
    vpc_id = aws_vpc.levelup_vpc.id
    cidr_block = var.LEVELUP_PRIVATE_SUBNET1_CIDR_BLOCK
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        name = "${var.ENVIRONMENT}-levelup-private-subnet1"
    }
}

# private subnet 2 

resource "aws_subnet" "levelup_private_subnet_2" {
    vpc_id = aws_vpc.levelup_vpc.id
    cidr_block = var.LEVELUP_PRIVATE_SUBNET2_CIDR_BLOCK
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
        name = "${var.ENVIRONMENT}-levelup-private-subnet2"
    }
}

# internet gateways

resource "aws_internet_gateway" "levelup-int-gw" {
    vpc_id = aws_vpc.levelup_vpc.id

    tags = {
        name = "${var.ENVIRONMENT}-levelup-vpc-internet-gateway"
    }
}

# elastic ip for nat gateway

resource "aws_eip" "levelup_nat_eip" {
    vpc = true
    depends_on = [ aws_internet_gateway.levelup-int-gw ]
}

# nat gateway for private ip

resource "aws_nat_gateway" "levelup_nat_gw" {
    allocation_id = aws_eip.levelup_nat_eip.id
    subnet_id = aws_subnet.levelup_public_subnet_1.id
    depends_on = [ aws_internet_gateway.levelup-int-gw ]

    tags = {
        name = "${var.ENVIRONMENT}-levelup-vpc-nat-gateway"
    }
}

# route table for public architecture

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.levelup_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.levelup-int-gw.id
    }

    tags = {
        name = "${var.ENVIRONMENT}-levelup-public-route-table"
    }
}

# route table for private architecture

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.levelup_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.levelup_nat_gw.id
    }

    tags = {
        name = "${var.ENVIRONMENT}-levelup-private-route-table"
    }
}

# route table association with public subnet 

resource "aws_route_table_association" "to_public_subnet1" {
    subnet_id = aws_subnet.levelup_public_subnet_1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "to_public_subnet2" {
    subnet_id = aws_subnet.levelup_public_subnet_2.id
    route_table_id = aws_route_table.public.id
}

# route table association with private subnet

resource "aws_route_table_association" "to_private_subnet1" {
    subnet_id = aws_subnet.levelup_private_subnet_1.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "to_private_subnet2" {
    subnet_id = aws_subnet.levelup_private_subnet_2.id
    route_table_id = aws_route_table.private.id
}

provider "aws" {
    region = var.AWS_REGION
}

# outputs 

output "my_vpc_id" {
    description = "VPC ID"
    value = aws_vpc.levelup_vpc.id
}

output "private_subnet_1" {
    description = "subnet id"
    value = aws_subnet.levelup_private_subnet_1.id
}

output "private_subnet_2" {
    description = "subnet id"
    value = aws_subnet.levelup_private_subnet_2.id
}

output "public_subnet_1" {
    description = "subnet id"
    value = aws_subnet.levelup_public_subnet_1.id
}

output "public_subnet_2" {
    description = "subnet id"
    value = aws_subnet.levelup_public_subnet_2.id
}