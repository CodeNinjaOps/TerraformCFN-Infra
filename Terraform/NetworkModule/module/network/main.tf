# aws vpc resources

resource "aws_vpc" "levelup-vpc" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = "true"
    enable_dns_support = "true"

    tags = {
        Environment = var.environment_tag
    }
}

#aws internet gateways

resource "aws_internet_gateway" "levelup-internet-gw" {
    vpc_id = aws_vpc.levelup-vpc.id

    tags = {
        Environment = var.environment_tag
    }
}

# aws subnet for vpc

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.levelup-vpc.id
    cidr_block = var.cidr_subnet
    map_public_ip_on_launch = "true"
    availability_zone = var.availability_zone

    tags = {
        Environment = var.environment_tag
    }
}

# aws route tables

resource "aws_route_table" "levelup-rtb-public" {
    vpc_id = aws_vpc.levelup-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.levelup-internet-gw.id
    }

    tags = {
        Environment = var.environment_tag
    }
}

# aws route table association

resource "aws_route_table_association" "levelup-rtba-public" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.levelup-rtb-public.id
}

# aws security groups

resource "aws_security_group" "levelup_sg_22" {
    name = "levelup_sg_22"
    vpc_id = aws_vpc.levelup-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Environment = var.environment_tag
    }
}

